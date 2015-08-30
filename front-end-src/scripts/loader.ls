/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

cbtool, prelude, Snap <- define <[ cbtool prelude snap ]>

{Obj, List} = prelude
{op2cbok} = cbtool

init = (sb)!->
	
	# h5px, 56pt
	r <-! op2cbok (
		sb.request-resource do
			\loading-screen.bloody-hand : \hand
		|> Obj.obj-to-pairs
		|> List.map (it) ->
			[
				it.0
				it.1 \
					switch
					| it.0 is \hand => offset-l: -4px
					| otherwise     => {}
			]
		|> Obj.pairs-to-obj
	)
	
	<-! sb.radio-trigger \game-block-init
	
	tpl-block = sb.get-tpl-block \loader
	
	do
		\.hand : r.hand
	|> sb.put-elems tpl-block
	
	tpl-block |> sb.put-tpl-block

destroy = (sb)!->
	#sb.radio-off

{init, destroy}
