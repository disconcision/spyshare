
import SpyShare

lx = []
a = ["1", "2", "3", "4", "5"]
b = tail a
c = tail b
d = "one" : b
e = "dos" : c
f = foldr (:) a ["blah", "gaah"]
w = ["blah", "gaah"] ++ a
y = concat [["blah", "gaah"], a]
x = concat [a, ["eins"]]
z = foldr (:) [] a


main = do showGraph [("a", a), ("b", b), ("c", c), ("d", d), ("e", e), ("f", f), ("w", w), ("x", x), ("y", y),  ("z", z)]