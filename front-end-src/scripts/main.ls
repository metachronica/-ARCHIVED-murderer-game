/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

<-! define

{
	pairs-to-obj
	camelize
	Obj
	map
	any
	each
} = require \prelude-ls

html = document.get-elements-by-tag-name \html .0

is-bool-field = (name) ->
	<[ is has ]> # prefixes
		|> map (-> "#{it}-")
		|> any (-> (name.index-of it) is 0)

cfg =
	<[
		is-debug
		revision
		static-dir
	]>
		|> map (-> [it, html.get-attribute "data-#{it}"]              )
		|> map (-> it.1 = it.1 is \true if it.0 |> is-bool-field ; it )
		|> map (-> it.0 |>= camelize ; it                             )
		|> pairs-to-obj

shim  = {}
paths =
	\promise : \shim/promise
	\prelude : \shim/prelude
	\cbtool  : \utils/cbtool

libs-paths =
	\es6-promise : \es6-promise/promise.min
	\jquery      : \jquery/dist/jquery.min
	\snap        : \snap.svg/dist/snap.svg-min

if cfg.is-debug
	libs-paths |>= Obj.map (-> it - /.min/ - /-min/)

# add static directory prefix for libs paths
libs-paths |>= Obj.map (-> "#{cfg.static-dir}/bower/#{it}")

paths <<< libs-paths

requirejs.config {
	base-url: "#{cfg.static-dir}/js/build"
	url-args: "
		v=#{
			unless cfg.is-debug
			then cfg.revision
			else do Date.now
		}
	"
	shim
	paths
}

$, cfg-module, loader, SandBox <-! requirejs <[ jquery cfg loader sandbox ]>

<-! $ # dom ready

$main-block = $ \#game
$main-block.0 ? throw new Error 'Fak. No game. No murders.'

{} <<< cfg <<< { $app: $main-block } |> cfg-module.set

main-sb = new SandBox \main

main-sb.radio-on \game-block-init, (cb) !->
	
	# already initialized
	if cfg-module.$game?
		do cb if cb?
		return
	
	$game = $ \<div/>, class: \game
	cfg-module.$app.html $game
	cfg-module.set $game: $game
	
	main-sb.radio-trigger \game-block-initialized, $game
	do cb if cb?

$w = $ window
$w.on \resize.main-sandbox, !->
	main-sb.radio-trigger \workspace-resized, $w.width!, $w.height!

loader-sb = new SandBox \loader
<[ init destroy ]>
	|> each (!-> loader[it] .= bind null, loader-sb)

do loader.init
