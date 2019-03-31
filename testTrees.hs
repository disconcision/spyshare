
import SpyShare

data Btree a = Node a (Btree a) (Btree a) | Leaf a

instance (Show a) => MemMappable (Btree a) where
    makeNode (Leaf x) = ((show x), [])
    makeNode (Node x y z) = ((show x), [y, z])

tree0 = Node "woo" (Node "bzz" (Leaf "yaa") (Leaf "yum")) (Leaf "boi")

main = do showGraph [("tree0", tree0)]