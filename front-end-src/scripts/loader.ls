/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

cbtool, prelude <- define <[ cbtool prelude ]>

{Obj} = prelude
{op2cbok} = cbtool

init = (sb)!->
	
	# h5px, 56pt
	r <-! op2cbok (
		sb.request-resource do
			\loading-screen.bloody-hand : \hand
		|> Obj.map (-> it {})
	)
	
	<-! sb.radio-trigger \game-block-init
	
	tpl-block = sb.get-tpl-block \loader
	tpl-block |> sb.put-tpl-block
	
	do
		\.hand : r.hand
	|> sb.put-elems tpl-block

destroy = (sb)!->
	#sb.radio-off

{init, destroy}
