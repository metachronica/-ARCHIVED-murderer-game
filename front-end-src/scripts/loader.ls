/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

cfg, R, cbtool, prelude, $ <- define <[ cfg resource cbtool prelude jquery ]>

{each, obj-to-pairs} = prelude
{p2cbok} = cbtool

initialize = ($wrapper)!->
	
	cfg.set $app: $wrapper
	{$app} = cfg
	
	resource = R.get \loading-screen
	
	death      <-! p2cbok resource \death, {}
	loader-bar <-! p2cbok resource \loader-bar, {}
	
	$ \#loader-tpl .text! |> $app.html
	
	do
		\.death        : death
		\.progress-bar : loader-bar
	|> obj-to-pairs
	|> each (!-> $app.find it.0 .get 0 |> it.1.append-to)

{initialize}
