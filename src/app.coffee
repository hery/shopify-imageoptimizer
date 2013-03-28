Batman.config.minificationErrors = false

# Create application and namespace
class ImageOptimizer extends Batman.App
  @root 'images#index'

class ImageOptimizer.ImagesController extends Batman.Controller
  routingKey:'images'
  index: ->
    # @set 'test','HEY!'

# Define model
class ImageOptimizer.Image extends Batman.Model
  @encode 'name'

window.ImageOptimizer = ImageOptimizer
ImageOptimizer.run()
