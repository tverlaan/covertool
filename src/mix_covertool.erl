-module(mix_covertool).

%% mix plugin callbacks
-export([start/2]).

-include("covertool.hrl").

%% ===================================================================
%% Mix plugin callbacks
%% ===================================================================
start( CompilePath, _Opts ) ->
    _ = cover:start(),

    case cover:compile_beam_directory(binary:bin_to_list(CompilePath)) of
        Results when is_list(Results) ->
            ok;
        {error, _} ->
            mix(raise, <<"Failed to cover compile directory">>)
    end,

    AppName = proplists:get_value(app, mix_project(config)),
    BeamDir = binary:bin_to_list(mix_project(compile_path)),
    Config = #config{appname = AppName, sources = ["./"], beams = [BeamDir]},

    fun() ->
        covertool:generate_report(Config, cover:modules())
    end.

%% ===================================================================
%% Mix helpers
%% ===================================================================
mix(Fun, Arg) ->
    'Elixir.Mix':Fun(Arg).

mix_project(Fun) ->
    'Elixir.Mix.Project':Fun().
