
module.exports = function(role, context, cb) {

  cb(null, context.modelName === 'abc')

};
