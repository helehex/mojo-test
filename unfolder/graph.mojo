from utils.index import StaticIntTuple as Ind
from array import Array
from table import Table, Row


struct Graph:
    var width: Int            # known,   = count_n-1.. at least for unfolder part 1
    var depth: Int            # unknown, < width + 1
    var node_count: Int       # unknown, < (count_n-1) * (width + 1)
    var edge_count: Int
    var max_edge_out: Int
    
    var history: Array[Int]   # history of origin selection
    
    var nodes: Table[Int]     # x = space, y = time     Int ~ unsorted id     accessed by [previous_node_index, depth]     0 = no node, {node_index + 1} = node
    var edges: Table[Int]     # x = edges, y = nodes    Int ~ weight          accessed by [node_index, node_index]         0 = no edge, {weight} = edge
    
    var weights: Array[Int]   # the nodes weights, can represent the self loop
    var bounds: Array[Ind[2]] # point[0] = edge_start, point[1] = edge_end
    
    var _xy_id: Array[Ind[2]] # to_point[unsorted id] = table coordinates
    var _lb_id: Array[Int]    # to_label[unsorted id] = sorted id
    var _id_lb: Array[Int]    # to_index[sorted id] = unsorted id


    #------ life ------#
    
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


    #------ index conversions ------#

    @always_inline
    fn id_xy(self, xy: Ind[2]) -> Int: return self.nodes[xy].__int__() - 1  # node-coordinates to node-id
    @always_inline
    fn lb_xy(self, xy: Ind[2]) -> Int: return self._lb_id[self.id_xy(xy)]   # node-coordinates to node-label
    @always_inline
    fn id_lb(self, lb: Int) -> Int: return self._id_lb[lb]                  # node-label to node-id
    @always_inline
    fn xy_lb(self, lb: Int) -> Ind[2]: return self._xy_id[self.id_lb(lb)]   # node-label to node-coordinates
    @always_inline
    fn xy_id(self, id: Int) -> Ind[2]: return self._xy_id[id]               # node-id to node-coordinates
    @always_inline
    fn lb_id(self, id: Int) -> Int: return self._lb_id[id]                  # node-id to node_label


    #------ format as a set of relations ------#

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