/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

cbtool, prelude, Snap <- define <[ cbtool prelude snap ]>

{op2cbok} = cbtool

init = (sb)!->
	
	# h5px, 56pt
	r <-! op2cbok sb.request-resource do
		\loading-screen.bloody-hand : [ \hand, offset-l: -4px ]
	
	<-! sb.radio-trigger \game-block-init
	
	tpl-block = sb.get-tpl-block \loader
	
	do
		\.hand : r.hand
	|> sb.put-elems tpl-block
	
	tpl-block |> sb.put-tpl-block

destroy = (sb)!->
	#sb.radio-off

{init, destroy}
