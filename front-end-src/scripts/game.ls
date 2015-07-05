/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(game-model, game-view) <- define <[models/game views/game]>

{GameModel} = game-model
{GameView}  = game-view

initialize = ($wrapper)!->
	model = new GameModel
	view  = new GameView {
		model
		cb: !->
			view.render!
			$wrapper.html view.$el
	}

{initialize}
