/**
 * main page handler
 *
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

require! {
	\../traits
}

export handler = (req, res) !->
	res.render \pages/main, traits.get!
