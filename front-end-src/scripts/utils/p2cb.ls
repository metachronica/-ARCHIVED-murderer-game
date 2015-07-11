/**
 * Promise to callback helper
 *
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

<- define

return (promise, cb) !->
	promise
		.then (!-> set-timeout (cb.bind null, null, it), 0)
		.fail (!-> set-timeout (cb.bind null, it      ), 0)
