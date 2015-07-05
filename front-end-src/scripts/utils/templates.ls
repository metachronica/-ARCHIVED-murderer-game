/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

($, U, Str) <- define <[jquery underscore Str]>

{dasherize, camelize} = Str

# templates list
<[
	loader
]>
.reduce ((it, name)->
	it[name |> camelize] =
		U.template ($ ".#{name |> dasherize}-tpl" .html!)
	it
), {}
