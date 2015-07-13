/**
 * basic view class
 *
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(B, async, svg) <- define <[ backbone async utils/svg ]>

{obj-to-pairs, pairs-to-obj, dasherize, Obj} = require \prelude-ls

{View} = B

class BasicView extends View
	
	tag-name: \div
	
	svg-resources: {}
	load-svg-resources: (cb)!~>
		
		(item) <~! (@svg-resources |> obj-to-pairs) .for-each
		
		const res = item.0 |> dasherize |> svg.get
		
		item.1
		|> obj-to-pairs
		|> (.map -> [it.0, (it.0 |> dasherize |> res _, it.1)])
		|> pairs-to-obj
		|> Obj.map (car)-> (cb)!-> car cb
		|> async.parallel _, (err, results)!~>
			return cb err if err?
			@svg[item.0] = results
			cb null, results
	
	get-region: (region-name)~>
		@$el.find ".#{region-name}" .get 0
	put-to-region: (region-name, el)!~~>
		@get-region region-name |> el.append-to
	
	initialize: (opts)!->
		super ...
		@game-model = opts.game-model
		@svg = {}

{BasicView}
