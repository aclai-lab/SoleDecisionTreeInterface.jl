using SoleLogics: intervals2D_in

representatives(fr::Full2DFrame, r::GlobalRel, ::Union{SingleAttributeMin,SingleAttributeMax}, ::Union{typeof(minimum),typeof(maximum)}) = intervals2D_in(1,X(fr)+1,1,Y(fr)+1)
representatives(fr::Full2DFrame, r::GlobalRel, ::SingleAttributeMax, ::typeof(maximum)) = [Interval2D(Interval(1,X(fr)+1), Interval(1,Y(fr)+1))  ]
representatives(fr::Full2DFrame, r::GlobalRel, ::SingleAttributeMin, ::typeof(minimum)) = [Interval2D(Interval(1,X(fr)+1), Interval(1,Y(fr)+1))  ]

# TODO correct?
# representatives(fr::Full2DFrame, r::GlobalRel, ::Union{SingleAttributeSoftMax,SingleAttributeSoftMin}, ::Union{typeof(minimum),typeof(maximum)}) = intervals2D_in(1,X(fr)+1,1,Y(fr)+1)
representatives(fr::Full2DFrame, r::GlobalRel, ::SingleAttributeSoftMax, ::typeof(maximum)) = [Interval2D(Interval(1,X(fr)+1), Interval(1,Y(fr)+1))  ]
representatives(fr::Full2DFrame, r::GlobalRel, ::SingleAttributeSoftMin, ::typeof(minimum)) = [Interval2D(Interval(1,X(fr)+1), Interval(1,Y(fr)+1))  ]

# TODO add bindings for Full2DFrame+IA and Full2DFrame+RCC
