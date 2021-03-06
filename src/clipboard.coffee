crypto = require 'crypto'

# Using clipboard in renderer process is not safe on Linux.
clipboard =
  if process.platform is 'linux'
    require('remote').require 'clipboard'
  else
    require 'clipboard'

# Extended: Represents the clipboard used for copying and pasting in Atom.
#
# An instance of this class is always available as the `atom.clipboard` global.
#
# ## Examples
#
# ```coffee
# atom.clipboard.write('hello')
#
# console.log(atom.clipboard.read()) # 'hello'
# ```
module.exports =
class Clipboard
  metadata: null
  signatureForMetadata: null

  # Creates an `md5` hash of some text.
  #
  # * `text` A {String} to hash.
  #
  # Returns a hashed {String}.
  md5: (text) ->
    crypto.createHash('md5').update(text, 'utf8').digest('hex')

  # Public: Write the given text to the clipboard.
  #
  # The metadata associated with the text is available by calling
  # {::readWithMetadata}.
  #
  # * `text` The {String} to store.
  # * `metadata` The additional info to associate with the text.
  write: (text, metadata) ->
    @signatureForMetadata = @md5(text)
    @metadata = metadata
    clipboard.writeText(text)

  # Public: Read the text from the clipboard.
  #
  # Returns a {String}.
  read: ->
    clipboard.readText()

  # Public: Read the text from the clipboard and return both the text and the
  # associated metadata.
  #
  # Returns an {Object} with the following keys:
  # * `text` The {String} clipboard text.
  # * `metadata` The metadata stored by an earlier call to {::write}.
  readWithMetadata: ->
    text = @read()
    if @signatureForMetadata is @md5(text)
      {text, @metadata}
    else
      {text}
