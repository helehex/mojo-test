from utils.index import StaticIntTuple as Ind
from array import Array
from table import Table, Row, reduce_max
from graph import Graph

fn say_the_thing(): print("hio world")


#------ Array[Int] to String
#
fn str_(o: Array[Int]) -> String:
    var s: String = "["
    for x in range(o._size - 1): s += String(o[x]) + ", "
    if o._size > 0: s += String(o[o._size - 1])
    s += "]"
    return s
fn print_(o: Array[Int]): print(str_(o))


#------ Array[Ind] to String
#
fn str_[size: Int](o: Array[Ind[size]]) -> String:
    var s: String = "["
    for x in range(o._size - 1): s += String(o[x]) + ", "
    if o._size > 0: s += String(o[o._size - 1])
    s += "]"
    return s
fn print_[size: Int](o: Array[Ind[size]]): print(str_[size](o))


#------ Table[Int] to String
#
# pad aligns each column
#
fn str_(o: Table[Int]) -> String:
    let room = len(String(reduce_max(o)))
    var s: String = ""
    for y in range(o._rows - 1): s += str_(Row(o,y), room) + "\n"
    if o._rows > 0: s += str_(Row(o, o._rows - 1), room)
    else: return "-"
    return s
fn print_(o: Table[Int]): print(str_(o))


#------ Row[Int] to String
#
# pad aligns each column
#
fn str_(o: Row[Int], pad: Int) -> String:
    var s: String = "{"
    var lm: Int = o._cols - 1
    @parameter
    fn _pad(i: Int):
        for rm in range(pad - len(String(o[i]))): s += " "
    for x in range(lm):
        _pad(x)
        s += String(o[x]) + ", "
    if o._cols > 0:
        _pad(lm)
        s += String(o[lm])
    s += "}"
    return s
fn str_(o: Row[Int]) -> String: return str_(o, len(String(reduce_max(o))))
fn print_(o: Row[Int]): print(str_(o))


#------ Graph to String
#
fn str_(o: Graph) -> String:
    var s: String = ""
    s += "history: " + str_(o.history) + "\n"
    s += "width: " + String(o.width) + "\n"
    s += "depth: " + String(o.depth) + "\n\n"
    s += "nodes: (count: " + String(o.node_count) + ")\n" + str_(o.nodes) + "\n"
    s += "weights: " + str_(o.weights) + "\n\n"
    s += "edges: (count: " + String(o.edge_count) + ", max_out: " + String(o.max_edge_out) + ")\n" + str_(o.edges) + "\n"
    s += "bounds: " + str_[2](o.bounds) + "\n\n"
    s += "id to xy: " + str_[2](o._xy_id) + "\n" # not infering parameter? is this expected?
    s += "id to lb: " + str_(o._lb_id) + "\n"
    s += "lb to id: " + str_(o._id_lb) + "\n"
    return s


#------ Graph (simple) to String
#
fn str_simple(o: Graph) -> String:
    var s: String = ""
    s += "history: " + str_(o.history) + "\n"
    s += "width: " + String(o.width) + "\n"
    s += "depth: " + String(o.depth) + "\n\n"
    s += "nodes: (count: " + String(o.node_count) + ")\n"
    s += "weights: " + str_(o.weights) + "\n\n"
    s += "edges: (count: " + String(o.edge_count) + ", max_out: " + String(o.max_edge_out) + ")\n"
    return s


#------ Graph (relations) to String
#
fn str_relations(o: Graph) -> String: #--- returns a string formatted as a set of relations: {1->2, 2->3, 3->0,...}
    var s: String = "{"
    for y in range(o.node_count):
        let start: Int = o.bounds[y][0]
        let limit: Int = o.bounds[y][1]
        for x in range(start, limit):
            if o.edges[Ind[2](x,y)] > 0:
                if len(s) != 1: s += ", "
                s += String(o.lb_id(y))+"->"+String(o.lb_id(x))
    return s + "}"