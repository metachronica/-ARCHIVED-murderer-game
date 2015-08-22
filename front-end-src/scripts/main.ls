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
} = require \prelude-ls

html = document.get-elements-by-tag-name \html .0

is-bool-field = (name)->
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
			else new Date!.getTime!
		}
	"
	shim
	paths
}

$, cfg-module, loader <-! requirejs <[ jquery cfg loader ]>

<-! $ # dom ready

const $game = $ \#game

unless $game.0?
	throw new Error 'Fak. No game. No murders.'

cfg-module.set cfg
loader.initialize $game
