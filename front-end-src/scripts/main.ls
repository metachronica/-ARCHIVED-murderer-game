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
} = require \prelude-ls

html = document.get-elements-by-tag-name \html .0

cfg =
	<[
		is-debug
		revision
		static-dir
	]>
	|> ( .map -> [it, html.get-attribute "data-#{it}"]          )
	|> ( .map -> it.1 = it.1 is \true if it.0 is \is-debug ; it )
	|> ( .map -> it.0 |>= camelize ; it                         )
	|> pairs-to-obj

shim  = {}
paths = {}

libs-paths =
	jquery:
		"jquery/dist/jquery#{unless cfg.is-debug then '.min' else ''}"
	snap:
		"snap.svg/dist/snap.svg#{unless cfg.is-debug then '-min' else ''}"
	underscore:
		"underscore/underscore#{unless cfg.is-debug then '-min' else ''}"
	backbone:
		"backbone/backbone#{unless cfg.is-debug then '-min' else ''}"
	async:
		"async/#{unless cfg.is-debug then 'dist/async.min' else 'lib/async'}"

# add static directory prefix for libs paths
libs-paths = libs-paths |> Obj.map (-> "#{cfg.static-dir}/bower/#{it}")

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

($) <-! requirejs <[ jquery ]>

$ html .data \cfg, cfg

unless document.get-element-by-id \game
	throw new Error 'Fak. No game. No murders.'

<-! $ # dom ready

(game) <-! requirejs <[ game ]>

game.initialize $ \#game
