/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

cfg, cbtool, prelude, sb <- define <[ cfg cbtool prelude sandbox ]>

{each, obj-to-pairs, map, camelize, pairs-to-obj, Obj} = prelude
{op2cbok} = cbtool

init = !->
	
	{$app} = cfg
	
	# h5px, 56pt
	r <-! op2cbok (
		sb.request-resource do
			\loading-screen.bloody-hand : \hand
		|> Obj.map (-> it {})
	)
	
	$game = $ \<div/>, class: \game
	$app.html $game
	cfg.set $game: $game
	
	$loader = $ \#loader-tpl .text! |> $
	$loader |> $game.html
	
	do
		\.hand : r.hand
	|> obj-to-pairs
	|> each (!-> $loader.find it.0 .get 0 |> it.1.append-to)

destroy = !->
	void

{init, destroy}
