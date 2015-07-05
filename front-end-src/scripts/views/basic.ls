/**
 * basic view class
 *
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(B) <- define <[backbone]>

{View} = B

class BasicView extends View
	
	tag-name: \div
	
	initialize: (opts)!->
		super ...
		@game = opts.game

{BasicView}
