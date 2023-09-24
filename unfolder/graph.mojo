from math import min, max
from utils.vector import DynamicVector as List
from utils.list import VariadicList as Para
from utils.index import StaticIntTuple as Ind
from array import Array
from table import Table, Row
from hio import _str


#------ Unfolder-Loop Graph, constructed from a previous step, or a history
#--- nodes are considered self-edges
#---
struct Graph:
    var width: Int            # known,   = count_n-1.. at least for unfolder part 1
    var depth: Int            # unknown, < width + 1
    var node_count: Int       # unknown, < (count_n-1) * (width + 1)
    var edge_count: Int
    var max_edge_out: Int
    
    var history: Array[Int]   # history of origin selection
    
    var nodes: Table[Int]     # x = space, y = time     Int ~ unsorted id     accessed by [previous_node_index, depth]     0 = no node, {node_index + 1} = node
    var edges: Table[Int]     # x = edges, y = nodes    Int ~ weight          accessed by [node_index, node_index]         0 = no edge, {weight} = edge
    
    var weights: Array[Int]   # the nodes weights, can represent the self loop.
    var bounds: Array[Ind[2]]   # point[0] = edge_start, point[1] = edge_end
    
    var _xy_id: Array[Ind[2]]   # to_point[unsorted id] = table coordinates
    var _lb_id: Array[Int]    # to_label[unsorted id] = sorted id
    var _id_lb: Array[Int]    # to_index[sorted id] = unsorted id
    
    @staticmethod
    fn follow(*history: Int) -> Self: #--------- follow origin history, and return the resulting graph at the end
        let hist: Para[Int] = Para[Int](history)
        var result: Self = Self()
        for i in range(len(hist)):
            result = Self.unfold(result,hist[i])
        return result^
    
    @staticmethod
    fn unfold(seed: Self, origin: Int) -> Self:
        
        let width: Int = seed.node_count # width of the resulting graph = node count of this graph
        
        # if the current graph is empty, give single (implicit) self-loop. (the 1 step)
        if seed.node_count <= 0 or seed.node_count < origin or origin < 1:
            
            return Self( #---------------- return step 1 :
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
        
        return Self(
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
    
    fn __init__(inout self):
        self.width = 0
        self.depth = 0
        self.node_count = 0
        self.edge_count = 0
        self.max_edge_out = 0
        self.history = Array[Int]()
        self.nodes = Table[Int]()
        self.edges = Table[Int]()
        self.weights = Array[Int]()
        self.bounds = Array[Ind[2]]()
        self._xy_id = Array[Ind[2]]()
        self._lb_id = Array[Int]()
        self._id_lb = Array[Int]()
        
    fn __init__
        (
        inout self,
        width: Int,
        depth: Int,
        node_count: Int,
        edge_count: Int,
        max_edge_out: Int,
        owned history: Array[Int],
        owned nodes: Table[Int],
        owned edges: Table[Int],
        owned weights: Array[Int],
        owned bounds: Array[Ind[2]],
        owned _xy_id: Array[Ind[2]],
        owned _lb_id: Array[Int],
        owned _id_lb: Array[Int]
        ):
        self.width = width
        self.depth = depth
        self.node_count = node_count
        self.edge_count = edge_count
        self.max_edge_out = max_edge_out
        self.history = history
        self.nodes = nodes
        self.edges = edges
        self.weights = weights
        self.bounds = bounds
        self._xy_id = _xy_id
        self._lb_id = _lb_id
        self._id_lb = _id_lb
        
    fn __moveinit__(inout self, owned other: Self):
        self.width = other.width
        self.depth = other.depth
        self.node_count = other.node_count
        self.edge_count = other.edge_count
        self.max_edge_out = other.max_edge_out
        self.history = other.history
        self.nodes = other.nodes
        self.edges = other.edges
        self.weights = other.weights
        self.bounds = other.bounds
        self._xy_id = other._xy_id
        self._lb_id = other._lb_id
        self._id_lb = other._id_lb

    @always_inline
    fn id_xy(self, xy: Ind[2]) -> Int: return self.nodes[xy].__int__() - 1  # node-coordinates to node-id
    @always_inline
    fn lb_xy(self, xy: Ind[2]) -> Int: return self._lb_id[self.id_xy(xy)]   # node-coordinates to node-label
    @always_inline
    fn id_lb(self, lb: Int) -> Int: return self._id_lb[lb]                # node-label to node-id
    @always_inline
    fn xy_lb(self, lb: Int) -> Ind[2]: return self._xy_id[self.id_lb(lb)]   # node-label to node-coordinates
    @always_inline
    fn xy_id(self, id: Int) -> Ind[2]: return self._xy_id[id]               # node-id to node-coordinates
    @always_inline
    fn lb_id(self, id: Int) -> Int: return self._lb_id[id]                # node-id to node_label



# ------ format as a set of relations

fn str_relations(o: Graph) -> String:
    var s: String = "{"
    for y in range(o.node_count):
        let start: Int = o.bounds[y][0]
        let limit: Int = o.bounds[y][1]
        for x in range(start, limit):
            if o.edges[Ind[2](x,y)] > 0:
                if len(s) != 1: s += ", "
                s += String(o.lb_id(y))+"->"+String(o.lb_id(x))
    return s + "}"