--- makefile for lua-5.1
--
if not WINDOWS then quit("We are not running on Windows?") end;
--
-----------------------------------------------------------------------------------------------
--
LUAROOT     = LUAROOT or PWD
LUA_BIN     = LUA_BIN or LUAROOT.."/_install"               -- install dir
TEMPDIR     = TEMPDIR or LUAROOT.."/tmp"                    -- dir for intermediate files

local LUA_VERSION = "51"
local LUA_IDIR    = LUA_BIN.."/include/"..LUA_VERSION -- dir for headers and static libs
local LUA_CDIR    = LUA_BIN.."/lib/"..LUA_VERSION     -- dir for c modules
local LUA_LDIR    = LUA_BIN.."/lua"                   -- dir for lua modules 
local LUA_ETC_DIR = LUA_BIN.."/etc"                   -- dir for documentation, tests, etc.
local LUA_SRC_DIR = LUAROOT.."/lua-5.1/src"           -- where are the lua sources.

local lua_core = "\z
  lapi lcode ldebug ldo ldump lfunc lgc llex lmem lobject \z
  lopcodes lparser lstate lstring ltable ltm lundump lvm lzio \z
  lauxlib lbaselib ldblib liolib \z
  lmathlib loslib lstrlib ltablib loadlib linit"

if not make.path.isDir("lua-5.1") then
  svn.checkout{"lua-5.1", "https://github.com/Fuzzlix/lua5/branches/51"}
end
--
local LUAICON = wresource {"lua51", src="icon", base=LUA_SRC_DIR, odir=TEMPDIR} -- icon resources
local LUAICN2 = wresource {"luac51",src="icon", base=LUA_SRC_DIR, odir=TEMPDIR} -- icon resources
local LUA_C   = c99 {"lua51", src="lua", base=LUA_SRC_DIR, odir=TEMPDIR, from="lua51:defines", cflags=CFLAGS}         -- lua program c source
local LUAC_C  = c99 {"lua51", src="luac print", base=LUA_SRC_DIR, odir=TEMPDIR, from="lua51s:defines", cflags=CFLAGS} -- luac program c source
local LIB_C   = c99 {"lua51_s", src=lua_core, base=LUA_SRC_DIR, odir=TEMPDIR, from="lua51s:defines", cflags=CFLAGS}   -- static lib c source
local DLL_C   = c99 {"lua51_d", src=lua_core, base=LUA_SRC_DIR, odir=TEMPDIR, from="lua51:defines", cflags=CFLAGS}    -- dynamic lib c source
--
local LUALIB  = c99.library {'lua51', odir=LUA_IDIR, inputs=LIB_C}                     -- static lua runtime lib
local LUADLL  = c99.shared  {'lua51', odir=LUA_BIN, inputs=DLL_C}                      -- dynamic lua runtime lib
local LUAEXE  = c99.program {'lua51', odir=LUA_BIN, inputs={LUA_C, LUAICON, LUADLL}}   -- lua executable
local LUAC    = c99.program {'luac51', odir=LUA_BIN, inputs={LUAC_C, LUAICN2, LUALIB}} -- luac executable
--
local LUAINC  = file {src="lua.h luaconf.h lualib.h lauxlib.h", base=LUA_SRC_DIR, odir=LUA_IDIR}
local LUADOC  = file {src="*", base=LUA_SRC_DIR.."/../doc", odir=LUA_ETC_DIR.."/lua51/doc"}
local LUAETC  = file {src="*.ico", base=LUA_SRC_DIR.."/../etc", odir=LUA_IDIR}
--
local LUA = group {LUAEXE, LUAC, LUALIB, LUAINC, LUADLL, LUADOC, LUAETC}

target("lua51", LUA)

default(LUA)
--
define_need{'lua51',  -- lua51, dynamically linked libs
  libs          = "lua51", 
  incdir        = LUA_IDIR, 
  defines       = "LUA_BUILD_AS_DLL", 
  libdir        = LUA_BIN .. " " .. LUA_IDIR,
  prerequisites = "lua51",
  LUAVERSION    = LUA_VERSION
};

define_need{'lua51s', -- lua51, statically linked libs
  libs          = "lua51",
  incdir        = LUA_IDIR, 
  --defines       = "LUA_COMPAT_MODULE", 
  libdir        = LUA_IDIR,
  prerequisites = "lua51",
  LUAVERSION    = LUA_VERSION
};
--
define_need "lua = lua51"   -- need alias.
define_need "luas = lua51s" -- need alias.

