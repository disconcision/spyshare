-- andrew blinn 2019

{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE FlexibleInstances #-}

module SpyShare where

import System.Mem.StableName
import System.IO.Unsafe
import System.Process 

import qualified Data.GraphViz as G
import qualified Data.GraphViz.Attributes.Complete as G
import qualified Data.GraphViz.Types as G

import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.IO as TL


class MemMappable x where
    makeNode :: x -> (String, [x])

instance (Show b) => MemMappable [b] where 
    makeNode [] = ("null", [])
    makeNode (x:xs) = ((show x), [xs])


type ID = Int
type TestData a = [(String, a)]
type MemoryTable = [(ID, (String, [ID]))]

type VLabel = String
type ELabel = String
type V = (ID, String)
type E = (ID, ID, String)
type Graph = ([V], [E])



-- get a unique id for the memory location where a is stored
getName :: a -> Int
getName !d = unsafePerformIO $ do
    n <- makeStableName $! d
    return $ hashStableName n


-- makes a table of memory locations of the provided test data
makeMemoryTable :: (MemMappable a) =>  TestData a -> MemoryTable
makeMemoryTable =
    concatMap (\ (variableName, ls) ->
        (getName variableName, (variableName, [getName ls])) : mapMem ls []) 


-- gets (name, [children]) from the instance and maps their memory locations                
mapMem :: (MemMappable a) => a -> MemoryTable -> MemoryTable
mapMem c table = case children of
    [] -> [(getName c, (name, []))]
    _  -> concat [(getName c, (name, [getName x])) : mapMem x table | x <- children]
    where (name, children) = makeNode c


-- generates a set of vertices and edges from test data
graph :: (MemMappable a) => TestData a -> Graph
graph d = ([(loc, label) | (loc, (label, _)) <- memoryTable],
           concat [[(loc, n, "next") | n <- next] | (loc, (label, next)) <- memoryTable])
         where memoryTable = makeMemoryTable d


-- Graph style settings         
graphStyleParams :: G.GraphvizParams ID VLabel ELabel () VLabel
graphStyleParams = G.defaultParams {
  G.globalAttributes =
    [ G.GraphAttrs [ G.RankDir   G.FromLeft
                   , G.BgColor   [G.toWColor G.White]]
    , G.NodeAttrs  [ G.shape     G.BoxShape
                   , G.FontColor fontColor
                   , G.FillColor (G.toColorList $ [fillColor])
                   , G.style     G.filled
                   ]],
  G.fmtNode = \(v, vl) -> case vl of
      _ -> [G.textLabel (TL.pack (vl)), --(vl ++ " : " ++ (show v))
            G.Color $ G.toColorList [ G.RGB 0 0 0 ]],
  G.fmtEdge = \(from, to, el) -> case el of
      "next" -> [ {-G.textLabel (TL.pack el),-}
                 G.Color $ G.toColorList [ G.RGB 255 0 0 ]]
      }  
  where
    fillColor = G.RGB 200 200 200
    fontColor = G.RGB 255 0 0
    

-- Writes a graph based on test data to a file and displays it
-- (requires imagemagick for display)
showGraph :: (MemMappable a) =>  TestData a -> IO ()  
showGraph td = do
    let (vs, es) = graph td
        tempFileName = "spyshare-temp"
        dotGraph = G.graphElemsToDot graphStyleParams vs es :: G.DotGraph ID
        dotText = G.printDotGraph dotGraph  :: TL.Text
    TL.writeFile (tempFileName ++ ".dot") $ dotText
    system $ "dot " ++ tempFileName ++ ".dot -Tpng > " ++ tempFileName ++ ".png"
    system ( "xdg-open " ++ tempFileName ++ ".png" ) >>= \exitCode -> print exitCode
    --system $ "rm " ++ tempFileName ++ ".png"
    --system ("rm " ++ tempFileName ++ ".dot") >>= \exitCode -> print exitCode


