/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

cbtool, prelude, Snap <- define <[ cbtool prelude snap ]>

{ op2cbok } = cbtool
{ List, Obj } = prelude

sb = null

tpl-block = null

hand = null
hand-init-size = null
hand-matrix = null

progress-bar  = null
bg-line       = null
progress-line = null

const line-attrs =
	stroke-width   : 5px
	stroke-linecap : \square

const blood-drop-offset = 93p
const offset-h = 60px

on-ws-resize = (ws-w, ws-h) !->
	
	min-size = do sb.get-min-size
	
	w = tpl-block.width!
	h = tpl-block.height!
	
	hand-size = w: 0, h: 0
	
	# with offset
	hand-init-size-o = w: 0, h: hand-init-size.h + offset-h
	hand-init-size-o.w =
		hand-init-size-o.h * hand-init-size.w / hand-init-size.h
	
	if ws-h < hand-init-size-o.h
		hand-size.h = Math.max min-size.h, ws-h |> (- offset-h)
		hand-size.w = hand-size.h * hand-init-size.w / hand-init-size.h
	else
		hand-size = hand-size <<< hand-init-size
	
	hand.attr do
		width:  hand-size.w
		height: hand-size.h
	
	matrix = do hand-matrix.clone
	matrix.scale <| hand-size.w / hand-init-size.w
	hand.general-element.transform matrix
	
	line-x =
		hand-size.w
			|> (* blood-drop-offset)
			|> (/ 100p)
	line-y = hand-size.h
	
	tpl-block.css height: (hand-size.h + offset-h)
	
	[ bg-line, progress-line ]
		|> List.each -> it.attr do
			x1: line-x
			x2: line-x
			y1: line-y
			y2: line-y
	
	bg-line.attr x2: \100%

init = (input-sb) !->
	
	sb := input-sb
	
	# font 56pt
	r <-! op2cbok sb.request-resource do
		\loading-screen.bloody-hand : [ \hand, offset-l: -4px ]
	
	<-! sb.radio-trigger \game-block-init
	
	tpl-block := sb.get-tpl-block \loader
	
	hand := r.hand
	hand-init-size :=
		do
			w: hand.attr \width
			h: hand.attr \height
		|> Obj.map (parse-int _, 10)
	hand-matrix := hand.general-element.transform!.local-matrix
	
	progress-bar := Snap! .attr width: \100%, height: \100%
	bg-line :=
		progress-bar
			.line 0, 0, 100px, 0
			.attr { stroke: \#333 } <<< line-attrs
	progress-line :=
		progress-bar
			.line 0, 0, 50px, 0
			.attr { stroke: \white } <<< line-attrs
	
	do
		\.hand         : hand
		\.progress-bar : progress-bar
	|> sb.put-elems tpl-block
	
	tpl-block |> sb.put-tpl-block
	
	sb.radio-on \workspace-resized, on-ws-resize
	ws-size = do sb.get-ws-size
	on-ws-resize ws-size.w, ws-size.h

destroy = !->
	
	sb.radio-off \workspace-resized, on-ws-resize
	
	do tpl-block.empty
	
	tpl-block := null
	
	hand := null
	hand-init-size := null
	hand-matrix := null
	
	bg-line       := null
	progress-line := null
	progress-bar  := null
	
	sb := null

{ init, destroy }
