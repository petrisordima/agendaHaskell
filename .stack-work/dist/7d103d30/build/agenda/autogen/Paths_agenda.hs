{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_agenda (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "D:\\Facultate\\ProgLogicasifunctionala\\stack\\agenda\\agenda\\.stack-work\\install\\6835b01e\\bin"
libdir     = "D:\\Facultate\\ProgLogicasifunctionala\\stack\\agenda\\agenda\\.stack-work\\install\\6835b01e\\lib\\x86_64-windows-ghc-8.4.4\\agenda-0.1.0.0-KRaYhW0tvN6KQ7fnHRRZ0y-agenda"
dynlibdir  = "D:\\Facultate\\ProgLogicasifunctionala\\stack\\agenda\\agenda\\.stack-work\\install\\6835b01e\\lib\\x86_64-windows-ghc-8.4.4"
datadir    = "D:\\Facultate\\ProgLogicasifunctionala\\stack\\agenda\\agenda\\.stack-work\\install\\6835b01e\\share\\x86_64-windows-ghc-8.4.4\\agenda-0.1.0.0"
libexecdir = "D:\\Facultate\\ProgLogicasifunctionala\\stack\\agenda\\agenda\\.stack-work\\install\\6835b01e\\libexec\\x86_64-windows-ghc-8.4.4\\agenda-0.1.0.0"
sysconfdir = "D:\\Facultate\\ProgLogicasifunctionala\\stack\\agenda\\agenda\\.stack-work\\install\\6835b01e\\etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "agenda_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "agenda_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "agenda_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "agenda_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "agenda_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "agenda_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "\\" ++ name)
