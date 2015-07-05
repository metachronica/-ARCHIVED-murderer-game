/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

<-! define

html = document.get-elements-by-tag-name \html .0
pairs-to-obj = (.reduce ((obj, it)-> obj[it.0] = it.1 ; obj), {})

cfg =
	<[
		is-debug
		revision
		static-dir
	]>
	.map (-> [it, html.get-attribute "data-#{it}"])
	.map (-> it.1 = it.1 is \true if it.0 is \is-debug ; it)
	.map (-> it.0 .= replace /-\w/ig, (-> it.slice 1 .to-upper-case!) ; it)
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

# add static directory prefix for libs paths
libs-paths =
	Object.keys libs-paths
	.map (-> [it, libs-paths[it]])
	.map (-> it.1 = "#{cfg.static-dir}/bower/#{it.1}" ; it)
	|> pairs-to-obj

paths <<< libs-paths

# prelude-ls paths
<[Func List Num Obj Str]>
.map (-> [
	it
	"
		#{cfg.static-dir}
		/js/prelude/build/
		#{it}
		#{unless cfg.is-debug then '.min' else ''}
	"
])
.reduce ((it, next)-> it[next.0] = next.1 ; it), {}
|> (!-> paths <<< it)

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

($) <-! require <[jquery]>

$ html .data \cfg, cfg

unless document.get-element-by-id \game
	throw new Error 'Fak. No game. No murders.'

<-! $ # dom ready

(game) <-! require <[game]>

game.initialize $ \#game
