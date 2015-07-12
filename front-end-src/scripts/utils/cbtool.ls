/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

<- define

{head, tail} = require \prelude-ls

cbok = (cb)-> !->
	args =  Array::slice.call arguments
	err  =  args |> head ; throw err if err?
	args |> tail |> cb.apply null, _

cbcar = (car, cb)->
	<-! car
	args =  Array::slice.call arguments
	err  =  args |> head ; throw err if err?
	args |> tail |> cb.apply null, _

p2cb = (promise, cb) !->
	promise
	.then (!-> set-timeout (cb.bind null, null, it), 0)
	.fail (!-> set-timeout (cb.bind null, it      ), 0)

{cbok, cbcar, p2cb}
