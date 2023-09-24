from math import min, max
from utils.vector import DynamicVector as List
from utils.list import VariadicList as Para
from utils.index import StaticIntTuple as Ind
from array import Array
from table import Table, Row
from graph import Graph


fn follow(*history: Int) -> Graph: #--------- follow origin history, and return the resulting graph at the end
    let hist: Para[Int] = Para[Int](history)
    var result: Graph = Graph()
    for i in range(len(hist)):
        result = unfold(result,hist[i])
    return result^
    

fn unfold(seed: Graph, origin: Int) -> Graph:
    
    let width: Int = seed.node_count # width of the resulting graph = node count of this graph
    
    # if the current graph is empty, give single (implicit) self-loop. (the 1 step)
    if seed.node_count <= 0 or seed.node_count < origin or origin < 1:
        
        return Graph( #---------------- return step 1 :
            1, #------------------------------------- width
            1, #------------------------------------- depth
            1, #------------------------------------- node_count
            0, #------------------------------------- edge_count
            0, #------------------------------------- max_edge_out
            Array[Int](seed.history, origin), #------ history
            Table[Int](1,1,1), #--------------------- nodes
            Table[Int](1,1,0), #--------------------- edges
            Array[Int](1,1), #----------------------- weights
            Array[Ind[2]](1,Ind[2](1,1)), #---------- bounds
            Array[Ind[2]](1,Ind[2](0,0)), #---------- _xy_id
            Array[Int](1,1), #----------------------- _lb_id
            Array[Int](2,0) #------------------------ _id_lb
            )
    
    #------------------- this graph has reached step > 1, start the crawling process
    var depth: Int = 0
    var max_depth: Int = 0
    var node_count: Int = 0
    var edge_count: Int = 0
    
    # estimate size of resulting graph
    let depth_est: Int = width + 1          #? edge estimate~ < seed edge_count * 3
    let node_est: Int = width * depth_est   #? node estimate~ < seed count * 3
    
    # create new containers for the resulting graph
    var nodes: Table[Int] = Table[Int](width, depth_est)
    var edges: Table[Int] = Table[Int](node_est, node_est)
    var weights: Array[Int] = Array[Int](node_est)
    var _xy_id: Array[Ind[2]] = Array[Ind[2]](node_est)
    
    # add origin node
    var _o: Int = seed.id_lb(origin)
    
    _xy_id[node_count] = Ind[2](_o,0)
    node_count += 1
    nodes[Ind[2](_o,0)] = node_count
    weights[0] += 1
    
    #--- start crawling the seed graph, adding new nodes to this graph along the way
    #---
    #--- when a node with at least one child which doesnt loop is reached, that childs index will be pushed onto the trace, and used to set the indexed mask true
    #--- when a node is reached where every child forms a loop, it's index will be popped from the trace, and used to set the indexed mask false
    #---
    var trace: List[Int] = List[Int](width)
    var mask: Array[Int] = Array[Int](width)  # mask contains the depth the trace was at when the index was pushed, +1. if it has not been reached, 0.
    var edge_start: Int = 0                   # the edge to start looping at
    var edge_limit: Int = 0                   # the edge to stop looping at
    var o_: Int = _o
    
    @parameter #--- main crawl loop
    fn _crawl():
        _push()
        while depth > 0:
            if _search(): _pop()  # search ended, pop trace  
            else: _push()        # search deepens, push trace  
    
    @parameter #--- push trace, and update mask
    fn _push():
        o_ = _o
        depth += 1
        mask[o_] = depth
        trace.push_back(o_)
        _touch()
        edge_start = seed.bounds[o_][0]
        edge_limit = seed.bounds[o_][1]
        _o = edge_start
        
    @parameter #--- pop trace, and update mask
    fn _pop():
        
        max_depth = max(depth, max_depth)  # check for max depth before pop
        depth -= 1                         # decrement depth
        mask[o_] = 0                       # set mask back to 0
        o_ = trace[max(0,depth-1)]
        _o = trace.pop_back() + 1          # .. + 1 is so dont keep repeating the same _o after you pop!
        edge_start = seed.bounds[o_][0]
        edge_limit = seed.bounds[o_][1]
        
    @parameter
    fn _search() -> Bool:       # search through connected edges
        while _o < edge_limit:
            if seed.edges[Ind[2](_o,o_)] > 0 and _check():
                _reach()
                return False      # check succeeded, continue deeper
            _o += 1
        return True               # all checks must fail to trigger a pop
        
    @parameter
    fn _check() -> Bool:   # check for continuation
        if mask[_o] > 0:
            _touch()
            return False     # loop encountered, return false
        return True          # keeps going, return true
        
    @parameter
    fn _reach(): # the walk did not touch itself, try adding the reached node
        let p_: Ind[2] = Ind[2](o_, depth - 1)
        let _p: Ind[2] = Ind[2](_o, depth)
        if nodes[_p] == 0:
            _xy_id[node_count] = _p
            node_count += 1
            nodes[_p] = node_count
        let i_: Int = nodes[p_] - 1
        let _i: Int = nodes[_p] - 1
        let i_i: Ind[2] = Ind[2](_i,i_)
        weights[_i] += 1
        if edges[i_i] == 0: edge_count += 1    #? maybe edge_count += Int(edges[i_i] == 0)
        edges[i_i] += 1
        
    @parameter
    fn _touch(): # the check has completed a loop, add a previously unrealized node
        _reach()
        let t_: Int = nodes[Ind[2](_o, depth)] - 1
        let _t: Int = nodes[Ind[2](_o, mask[_o] - 1)] - 1
        let t_t: Ind[2] = Ind[2](_t,t_)
        if edges[t_t] == 0: edge_count += 1
        edges[t_t] += 1
        
    _crawl()
    _ = trace
    _ = mask
    depth = max_depth + 1
    #---
    #---
    #------ end cawl

    var bounds: Array[Ind[2]] = Array[Ind[2]](node_count)
    var _lb_id: Array[Int] = Array[Int](node_count)
    var _id_lb: Array[Int] = Array[Int](node_count + 1)
    var max_edge_out: Int = 0
    var l: Int = 0
    
    # Find edge_start and edge_limit for each nodes edge row
    for y in range(node_count):
        let row = Row(edges,y)
        var start: Int = node_count
        var limit: Int = 0
        var edge_out: Int = 0
        for x in range(node_count):
            if row[x] > 0:
                edge_out += 1
                start = min(x, start)
                limit = max(x, limit)
        max_edge_out = max(edge_out, max_edge_out)
        bounds[y] = Ind[2](start, limit + 1)
        
    # Label nodes chronologically. the main proccess usually confuses the node labeling, so this helps keep history consitent
    for y in range(depth):
        for x in range(width):
            var i: Int = nodes[Ind[2](x,y)] # the tables entry at x,y
            if i > 0:
                i -= 1
                l += 1
                _id_lb[l] = i
                _lb_id[i] = l
    #; debug / estimates error
    
    return Graph(
        width,
        depth,
        node_count,
        edge_count,
        max_edge_out,
        Array[Int](seed.history, origin),
        Table[Int](width, depth, nodes^),
        Table[Int](node_count, node_count, edges^),
        Array[Int](node_count, weights^),
        bounds^,
        Array[Ind[2]](node_count, _xy_id^),
        _lb_id^,
        _id_lb^
        )