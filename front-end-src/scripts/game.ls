/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

($, LoaderView) <-! define <[jquery views/loader]>

$game = $ \#game
throw new Error 'Fak. No game. No murders.' if $game.length is 0

new LoaderView!
