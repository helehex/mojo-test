from utils.index import StaticIntTuple as Ind
from collec.array import Array
from collec.table import Table, Row, reduce_max
from collec.graph import Graph

# format an array of <Int> as a <String>
fn _str(o: Array[Int]) -> String:
    var s: String = "["
    for x in range(o._size - 1): s += String(o[x]) + ", "
    if o._size > 0: s += String(o[o._size - 1])
    s += "]"
    return s
fn _print(o: Array[Int]): print(_str(o))

# format an array of <Ind> as a <String>
fn _str[size: Int](o: Array[Ind[size]]) -> String:
    var s: String = "["
    for x in range(o._size - 1): s += String(o[x]) + ", "
    if o._size > 0: s += String(o[o._size - 1])
    s += "]"
    return s
fn _print[size: Int](o: Array[Ind[size]]): print(_str[size](o))

# format a table of <Int> as a <String>
fn _str(o: Table[Int]) -> String:
    let room = len(String(reduce_max(o)))
    var s: String = ""
    for y in range(o._rows - 1): s += _str(Row(o,y), room) + "\n"
    if o._rows > 0: s += _str(Row(o, o._rows - 1), room)
    else: return "-"
    return s
fn _print(o: Table[Int]): print(_str(o))

# pad aligns each column when formatting
fn _str(o: Row[Int], pad: Int) -> String:
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
fn _str(o: Row[Int]) -> String: return _str(o, len(String(reduce_max(o))))
fn _print(o: Row[Int]): print(_str(o))

fn _str(o: Graph) -> String:
    var s: String = ""
    s += "history: " + _str(o.history) + "\n"
    s += "width: " + String(o.width) + "\n"
    s += "depth: " + String(o.depth) + "\n\n"
    s += "nodes: (count: " + String(o.node_count) + ")\n" + _str(o.nodes) + "\n"
    s += "weights: " + _str(o.weights) + "\n\n"
    s += "edges: (count: " + String(o.edge_count) + ", max_out: " + String(o.max_edge_out) + ")\n" + _str(o.edges) + "\n"
    s += "bounds: " + _str[2](o.bounds) + "\n\n"
    s += "id to xy: " + _str[2](o._xy_id) + "\n" # not infering parameter? is this expected?
    s += "id to lb: " + _str(o._lb_id) + "\n"
    s += "lb to id: " + _str(o._id_lb) + "\n"
    return s