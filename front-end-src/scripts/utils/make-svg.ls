/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

($) <- define <[jquery]>

const NS = 'http://www.w3.org/2000/svg'

do
	svg: -> $ document.create-element-NS NS, \svg
	$el: (tag-name)-> $ document.create-element-NS NS, tag-name
