/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

cfg, R, cbtool, prelude, $ <- define <[ cfg resource cbtool prelude jquery ]>

{each, obj-to-pairs, map, camelize, pairs-to-obj} = prelude
{op2cbok} = cbtool

initialize = ($wrapper)!->
	
	cfg.set $app: $wrapper
	{$app} = cfg
	
	resource = R.get \loading-screen
	
	res-promises =
		<[ death loader-bar ]>
			|> map (-> [ (it |> camelize), (resource it, {}) ])
			|> pairs-to-obj
	
	results <-! op2cbok res-promises
	{death, loader-bar} = results
	
	$game = $ \<div/>, class: \game
	$app.html $game
	cfg.set $game: $game
	
	$loader = $ \#loader-tpl .text! |> $
	$loader |> $game.html
	
	do
		\.death        : death
		\.progress-bar : loader-bar
	|> obj-to-pairs
	|> each (!-> $loader.find it.0 .get 0 |> it.1.append-to)

{initialize}
