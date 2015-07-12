/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

($, U) <- define <[ jquery underscore ]>

{
	dasherize
	camelize
	pairs-to-obj
} = require \prelude-ls

# templates list
<[
	loader
]>
|> (.map -> [
	it |> camelize
	U.template ($ ".#{it |> dasherize}-tpl" .html!)
])
|> pairs-to-obj
