-module(elvis_SUITE).

-export([
         all/0
        ]).

-export([
         rock_with_empty_config/1,
         rock_with_incomplete_config/1,
         rock_with_file_config/1,
         check_configuration/1,
         find_file_and_check_src/1
        ]).

-define(EXCLUDED_FUNS,
        [
         module_info,
         all,
         test,
         init_per_suite,
         end_per_suite
        ]).

-type config() :: [{atom(), term()}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Common test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-spec all() -> [atom()].
all() ->
    Exports = elvis_SUITE:module_info(exports),
    [F || {F, _} <- Exports,
          lists:all(fun(E) -> E /= F end, ?EXCLUDED_FUNS)].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test Cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-spec rock_with_empty_config(config()) -> any().
rock_with_empty_config(_Config) ->
    ok = try
             elvis:rock([]),
             fail
         catch
             throw:invalid_config -> ok
         end.

-spec rock_with_incomplete_config(config()) -> any().
rock_with_incomplete_config(_Config) ->
    ElvisConfig = [{src_dirs, ["src"]}],
    ok = try
             elvis:rock(ElvisConfig),
             fail
         catch
             throw:invalid_config -> ok
         end.

-spec rock_with_file_config(config()) -> ok.
rock_with_file_config(_Config) ->
    ok = elvis:rock().

-spec check_configuration(config()) -> any().
check_configuration(_Config) ->
    Config = [
              {src_dirs, ["src", "test"]},
              {rules, []}
             ],
    ["src", "test"] = elvis_utils:source_dirs(Config),
    [] = elvis_utils:rules(Config).

-spec find_file_and_check_src(config()) -> any().
find_file_and_check_src(_Config) ->
    Dir = "../../test/examples",

    []= elvis_utils:find_file(Dir, "doesnt_exist.erl"),
    [Path] = elvis_utils:find_file(Dir, "small.erl"),

    {ok, <<"-module(small).\n">>} = elvis_utils:src([], Path),
    {error, enoent} = elvis_utils:src([], "doesnt_exist.erl").
