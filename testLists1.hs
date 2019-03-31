
import SpyShare

list0 = ["A", "B", "C", "D"]
list1 = tail list0
list2 = "Z" : list0
list3 = list0 ++ list0
list4 = concat [list0, list0]

main = do showGraph [("list0", list0),
                     ("list1", list1),
                     ("list2", list2),
                     ("list3", list3),
                     ("list4", list4)]