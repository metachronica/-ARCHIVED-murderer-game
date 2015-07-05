/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(
	$, B, loader-view, Str
) <- define <[
	jquery backbone views/loader Str
]>

{Model} = B
{LoaderView} = loader-view

class Game extends Model
	
	@at-start-selector = \.at-start
	
	initialize: (opts)->
		super ...
		
		loader = new LoaderView do
			game: @
			cb: !~>
				
				# remove before js load text
				$ @@at-start-selector, @get \$el .remove!
				
				loader.render!
				
				@get \$el .html loader.$el

{Game}
