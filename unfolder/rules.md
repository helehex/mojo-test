Unfolder Rule:
- Nodes are considered self-edges
- Starting at node `N` in graph `G`, and using un-directed edges, track all possible paths which end on a repeated node.
- label the new nodes as you walk `[old label, steps to reach]`.
- we'll call the repeated nodes `l`, and `l+`. We treat `l+` as a new node.
- Combine all paths using the new labels to get `G~N`

Unfolder-Loop Rule:
- Nodes are considered self-edges
- Starting at node `N` in graph `G`, and using directed edges, track all possible paths which end on a repeated node.
- label the new nodes as you walk `[old label, steps to reach]`.
- we'll call the repeated nodes `l`, and `l+`. We treat `l+` as a new node.
- For each path, add a directed edge from `l+` to `l`.
- Combine all paths using the new labels to get `G~N`
- weights always 1