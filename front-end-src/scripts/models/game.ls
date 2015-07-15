/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(B) <- define <[ backbone ]>

{Model} = B
{obj-to-pairs} = require \prelude-ls

class GameModel extends Model
	defaults:
		\source-height : 1080
		\ratio : [16, 9]

{GameModel}
