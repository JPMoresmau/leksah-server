{-# LANGUAGE ScopedTypeVariables, BangPatterns, OverloadedStrings #-}
-----------------------------------------------------------------------------
--
-- Module      :  IDE.Utils.VersionUtils
-- Copyright   :  2007-2011 Juergen Nicklisch-Franken, Hamish Mackenzie
-- License     :  GPL Nothing
--
-- Maintainer  :  maintainer@leksah.org
-- Stability   :  provisional
-- Portability :
--
-- |
--
-----------------------------------------------------------------------------

module IDE.Utils.VersionUtils (
    getHaddockVersion
,   getGhcVersion
,   getGhcInfo
) where

import IDE.Utils.Tool (ToolOutput(..), runTool')
import Data.Char (ord)
import System.Log.Logger (debugM)
import Control.Exception as E (SomeException, catch)
import qualified Data.Text as T (unlines, unpack, init, last)
import Data.Text (Text)
import Control.DeepSeq (deepseq)

getGhcVersion :: IO FilePath
getGhcVersion = E.catch (do
    (!output,_) <- runTool' "ghc" ["--numeric-version"] Nothing
    let vers = head [l | ToolOutput l <- output]
        vers2 = if ord (T.last vers) == 13
                    then T.init vers
                    else vers
    debugM "leksah-server" $ "Got GHC Version " ++ T.unpack vers2
    output `deepseq` return $ T.unpack vers2
    ) $ \ (e :: SomeException) -> error $ "FileUtils>>getGhcVersion failed with " ++ show e

getGhcInfo :: IO Text
getGhcInfo = E.catch (do
    (!output,_) <- runTool' "ghc" ["--info"] Nothing
    output `deepseq` return $ T.unlines [l | ToolOutput l <- output]
    ) $ \ (e :: SomeException) -> error $ "FileUtils>>getGhcInfo failed with " ++ show e

getHaddockVersion :: IO Text
getHaddockVersion = E.catch (do
    (!output,_) <- runTool' "haddock" ["--version"] Nothing
    let vers = head [l | ToolOutput l <- output]
        vers2 = if ord (T.last vers) == 13
                    then T.init vers
                    else vers
    output `deepseq` return vers2
    ) $ \ (e :: SomeException) -> error $ "FileUtils>>getHaddockVersion failed with " ++ show e



