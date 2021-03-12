var mongoose = require('mongoose');

var sessionSchema = new mongoose.Schema({
    weekNo: {
        type: Number,
        required: false
    },
    date: {
        type: Date,
        required: true
    },
    class: {
        type: mongoose.Types.ObjectId,
        required: true,
        ref: 'ClassList'
    },
    attended: {
        type: Array,
        default: []
    },
    active: {
        type: Boolean,
        default: false
    }
},
    { timestamps: true });


var schema = new mongoose.Schema({
    className: {
        type: String,
        required: true
    },
    classType: {
        type: String,
        required: true
    },
    moduleId: {
        type: mongoose.Types.ObjectId,
        required: true
    },
    acadYear: {
        type: String,
        required: true
    },
    students: {
        type: Array,
        required: false,
        default: []
    },
    evenOdd: {
        type: Number,
        required: true
    },
    dayOfWeek: {
        type: Number,
        required: true
    },
    startTime: {
        type: String,
        required: true
    },
    endTime: {
        type: String,
        required: true
    },
    location: {
        type: String,
        required: true,
        default: ''
    }
},
    { timestamps: true, toJSON: { virtuals: true }, toObject: { virtuals: true }});

schema.virtual('sessions', {
    ref: 'Session',
    localField: '_id',
    foreignField: 'class'
});

mongoose.model('ClassList', schema);
mongoose.model('Session', sessionSchema);


module.exports = {
    ClassList: mongoose.model('ClassList'),
    Session: mongoose.model('Session')
}