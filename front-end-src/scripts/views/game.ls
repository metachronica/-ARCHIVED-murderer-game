/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(
	$, B, loader-view
) <- define <[
	jquery backbone views/loader
]>

{View} = B
{LoaderView} = loader-view

class GameView extends View
	
	tag-name: \div
	class-name: \game
	
	initialize: (opts)!->
		super ...
		
		@init-cb
		
		@loader-view = new LoaderView do
			game-model: @model
			cb: opts.cb
	
	render: !->
		@loader-view.render!
		@$el .html @loader-view.$el

{GameView}
