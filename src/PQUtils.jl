"""
`execute(path)`

Return the result of SQL file `path` execution. 
"""
function execute(conn,path)
    f = readlines(path)
    SQL = prod(f .* "\n")

    res = LibPQ.execute(conn,SQL)
    
    return res
end