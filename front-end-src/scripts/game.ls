/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

($, LoaderView) <-! define <[jquery views/loader]>

$game = $ \#game
$at-start = $ \.at-start, $game

(err, loader-view) <-! new LoaderView $game
throw err if err?

$at-start.remove!
