module MultipartPost
  VERSION = "1.0"
end

require File.dirname(__FILE__) + '/multipart-post/parts'
require File.dirname(__FILE__) + '/multipart-post/composite_io'
require File.dirname(__FILE__) + '/multipart-post/multipartable'
require File.dirname(__FILE__) + '/multipart-post/net/http/post/multipart'
