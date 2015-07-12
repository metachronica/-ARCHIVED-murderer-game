/**
 * basic view class
 *
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(B) <- define <[ backbone ]>

{View} = B

class BasicView extends View
	
	tag-name: \div
	
	get-region: (region-name)~>
		@$el.find ".#{region-name}" .get 0
	put-to-region: (region-name, el)!~~>
		@get-region region-name |> el.append-to
	
	initialize: (opts)!->
		super ...
		@game-model = opts.game-model

{BasicView}
