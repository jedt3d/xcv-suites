#tag Class
Protected Class WebRectangleXCV
Inherits WebCanvas
	#tag Event
		Sub Paint(g As WebGraphics)
		  Var canvasWidth As Integer = g.Width
		  Var canvasHeight As Integer = g.Height
		  
		  If canvasWidth <= 0 Or canvasHeight <= 0 Then Return
		  
		  g.ClearRectangle(0, 0, canvasWidth, canvasHeight)
		  
		  Var borderPixels As Integer = EffectiveBorderThickness(canvasWidth, canvasHeight)
		  Var drawBorder As Boolean = BorderEnabled And borderPixels > 0
		  Var fillColor As Color = FillColor
		  Var drawFill As Boolean = fillColor.Alpha < 255
		  
		  Var outerTopLeftRadius As Integer
		  Var outerTopRightRadius As Integer
		  Var outerBottomLeftRadius As Integer
		  Var outerBottomRightRadius As Integer
		  Var topLeftStyle As CornerStyles
		  Var topRightStyle As CornerStyles
		  Var bottomLeftStyle As CornerStyles
		  Var bottomRightStyle As CornerStyles
		  
		  ResolveOuterCornerMetrics(canvasWidth, canvasHeight, outerTopLeftRadius, outerTopRightRadius, outerBottomLeftRadius, outerBottomRightRadius, topLeftStyle, topRightStyle, bottomLeftStyle, bottomRightStyle)
		  
		  If drawFill Then
		    If drawBorder Then
		      Var innerWidth As Integer = canvasWidth - (borderPixels * 2)
		      Var innerHeight As Integer = canvasHeight - (borderPixels * 2)
		      
		      If innerWidth > 0 And innerHeight > 0 Then
		        Var innerTopLeftRadius As Integer
		        Var innerTopRightRadius As Integer
		        Var innerBottomLeftRadius As Integer
		        Var innerBottomRightRadius As Integer
		        
		        InsetResolvedCornerRadii(borderPixels, innerWidth, innerHeight, outerTopLeftRadius, outerTopRightRadius, outerBottomLeftRadius, outerBottomRightRadius, innerTopLeftRadius, innerTopRightRadius, innerBottomLeftRadius, innerBottomRightRadius)
		        DrawFillRows(g, borderPixels, innerWidth, innerHeight, innerTopLeftRadius, innerTopRightRadius, innerBottomLeftRadius, innerBottomRightRadius, topLeftStyle, topRightStyle, bottomLeftStyle, bottomRightStyle, fillColor)
		      End If
		    Else
		      DrawFillRows(g, 0, canvasWidth, canvasHeight, outerTopLeftRadius, outerTopRightRadius, outerBottomLeftRadius, outerBottomRightRadius, topLeftStyle, topRightStyle, bottomLeftStyle, bottomRightStyle, fillColor)
		    End If
		  End If
		  
		  If drawBorder Then
		    Var innerWidth As Integer = canvasWidth - (borderPixels * 2)
		    Var innerHeight As Integer = canvasHeight - (borderPixels * 2)
		    Var hasInnerShape As Boolean = innerWidth > 0 And innerHeight > 0
		    Var innerTopLeftRadius As Integer
		    Var innerTopRightRadius As Integer
		    Var innerBottomLeftRadius As Integer
		    Var innerBottomRightRadius As Integer
		    
		    If hasInnerShape Then
		      InsetResolvedCornerRadii(borderPixels, innerWidth, innerHeight, outerTopLeftRadius, outerTopRightRadius, outerBottomLeftRadius, outerBottomRightRadius, innerTopLeftRadius, innerTopRightRadius, innerBottomLeftRadius, innerBottomRightRadius)
		    End If
		    
		    DrawBorderRows(g, borderPixels, canvasWidth, canvasHeight, outerTopLeftRadius, outerTopRightRadius, outerBottomLeftRadius, outerBottomRightRadius, topLeftStyle, topRightStyle, bottomLeftStyle, bottomRightStyle, hasInnerShape, innerWidth, innerHeight, innerTopLeftRadius, innerTopRightRadius, innerBottomLeftRadius, innerBottomRightRadius)
		  End If
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function ApplyCoverage(baseColor As Color, coverage As Double) As Color
		  Var visibleFraction As Double = (255.0 - baseColor.Alpha) / 255.0
		  Var combinedVisible As Double = visibleFraction * ClampDouble(coverage, 0.0, 1.0)
		  Var alpha As Integer = Round(255.0 * (1.0 - combinedVisible))
		  
		  Return Color.RGB(baseColor.Red, baseColor.Green, baseColor.Blue, alpha)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ClampDouble(value As Double, minimum As Double, maximum As Double) As Double
		  If value < minimum Then Return minimum
		  If value > maximum Then Return maximum
		  
		  Return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ClampInteger(value As Integer, minimum As Integer, maximum As Integer) As Integer
		  If value < minimum Then Return minimum
		  If value > maximum Then Return maximum
		  
		  Return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawBorderRows(g As WebGraphics, borderPixels As Integer, canvasWidth As Integer, canvasHeight As Integer, outerTopLeftRadius As Integer, outerTopRightRadius As Integer, outerBottomLeftRadius As Integer, outerBottomRightRadius As Integer, topLeftStyle As CornerStyles, topRightStyle As CornerStyles, bottomLeftStyle As CornerStyles, bottomRightStyle As CornerStyles, hasInnerShape As Boolean, innerWidth As Integer, innerHeight As Integer, innerTopLeftRadius As Integer, innerTopRightRadius As Integer, innerBottomLeftRadius As Integer, innerBottomRightRadius As Integer)
		  For row As Integer = 0 To canvasHeight - 1
		    Var outerLeftX As Double
		    Var outerRightX As Double
		    
		    GetRowSpan(row, canvasWidth, canvasHeight, outerTopLeftRadius, outerTopRightRadius, outerBottomLeftRadius, outerBottomRightRadius, topLeftStyle, topRightStyle, bottomLeftStyle, bottomRightStyle, outerLeftX, outerRightX)
		    
		    If hasInnerShape And row >= borderPixels And row < borderPixels + innerHeight Then
		      Var innerRow As Integer = row - borderPixels
		      Var innerLeftX As Double
		      Var innerRightX As Double
		      
		      GetRowSpan(innerRow, innerWidth, innerHeight, innerTopLeftRadius, innerTopRightRadius, innerBottomLeftRadius, innerBottomRightRadius, topLeftStyle, topRightStyle, bottomLeftStyle, bottomRightStyle, innerLeftX, innerRightX)
		      
		      Var innerStartX As Double = borderPixels + innerLeftX
		      Var innerEndX As Double = borderPixels + innerRightX
		      
		      DrawHorizontalSpan(g, row, outerLeftX, innerStartX, BorderColor)
		      DrawHorizontalSpan(g, row, innerEndX, outerRightX, BorderColor)
		    Else
		      DrawHorizontalSpan(g, row, outerLeftX, outerRightX, BorderColor)
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawFillRows(g As WebGraphics, inset As Integer, drawWidth As Integer, drawHeight As Integer, topLeftRadius As Integer, topRightRadius As Integer, bottomLeftRadius As Integer, bottomRightRadius As Integer, topLeftStyle As CornerStyles, topRightStyle As CornerStyles, bottomLeftStyle As CornerStyles, bottomRightStyle As CornerStyles, fillColor As Color)
		  For row As Integer = 0 To drawHeight - 1
		    Var leftX As Double
		    Var rightX As Double
		    
		    GetRowSpan(row, drawWidth, drawHeight, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius, topLeftStyle, topRightStyle, bottomLeftStyle, bottomRightStyle, leftX, rightX)
		    DrawHorizontalSpan(g, inset + row, inset + leftX, inset + rightX, fillColor)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawHorizontalSpan(g As WebGraphics, row As Integer, leftX As Double, rightX As Double, baseColor As Color)
		  If row < 0 Or row >= g.Height Then Return
		  
		  Var clippedLeftX As Double = ClampDouble(leftX, 0.0, g.Width)
		  Var clippedRightX As Double = ClampDouble(rightX, 0.0, g.Width)
		  
		  If clippedRightX <= clippedLeftX Then Return
		  
		  Var startPixel As Integer = Floor(clippedLeftX)
		  Var endPixel As Integer = Ceiling(clippedRightX) - 1
		  
		  startPixel = ClampInteger(startPixel, 0, g.Width - 1)
		  endPixel = ClampInteger(endPixel, 0, g.Width - 1)
		  
		  If endPixel < startPixel Then Return
		  
		  If startPixel = endPixel Then
		    g.DrawingColor = ApplyCoverage(baseColor, clippedRightX - clippedLeftX)
		    g.FillRectangle(startPixel, row, 1, 1)
		    Return
		  End If
		  
		  Var startCoverage As Double = ClampDouble((startPixel + 1.0) - clippedLeftX, 0.0, 1.0)
		  Var endCoverage As Double = ClampDouble(clippedRightX - endPixel, 0.0, 1.0)
		  Var middleStart As Integer = startPixel + 1
		  Var middleEnd As Integer = endPixel - 1
		  
		  If startCoverage > 0.0 Then
		    g.DrawingColor = ApplyCoverage(baseColor, startCoverage)
		    g.FillRectangle(startPixel, row, 1, 1)
		  End If
		  
		  If middleEnd >= middleStart Then
		    g.DrawingColor = baseColor
		    g.FillRectangle(middleStart, row, middleEnd - middleStart + 1, 1)
		  End If
		  
		  If endCoverage > 0.0 Then
		    g.DrawingColor = ApplyCoverage(baseColor, endCoverage)
		    g.FillRectangle(endPixel, row, 1, 1)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EffectiveBorderThickness(canvasWidth As Integer, canvasHeight As Integer) As Integer
		  If Not BorderEnabled Then Return 0
		  
		  Var maxThickness As Integer = MinInteger(canvasWidth, canvasHeight) \ 2
		  Return ClampInteger(Round(BorderThickness), 0, maxThickness)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EffectiveCornerRadius(enabled As Boolean, requestedValue As Double, canvasWidth As Integer, canvasHeight As Integer) As Integer
		  If Not CornerAllEnabled Or Not enabled Then Return 0
		  
		  Var cornerValue As Double = MaxDouble(0.0, requestedValue)
		  
		  Select Case CornerUnit
		  Case CornerUnits.Percent
		    // Percent values are measured against half of the shorter side so 100 means "maximum useful corner".
		    Var percentBase As Double = MinInteger(canvasWidth, canvasHeight) / 2.0
		    Return MaxInteger(0, Round(percentBase * (cornerValue / 100.0)))
		  Else
		    Return MaxInteger(0, Round(cornerValue))
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EffectiveCornerStyle(enabled As Boolean, requestedStyle As CornerStyles) As CornerStyles
		  If Not CornerAllEnabled Or Not enabled Then Return CornerStyles.Rounded
		  
		  Return requestedStyle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub GetRowSpan(row As Integer, drawWidth As Integer, drawHeight As Integer, topLeftRadius As Integer, topRightRadius As Integer, bottomLeftRadius As Integer, bottomRightRadius As Integer, topLeftStyle As CornerStyles, topRightStyle As CornerStyles, bottomLeftStyle As CornerStyles, bottomRightStyle As CornerStyles, ByRef leftX As Double, ByRef rightX As Double)
		  Var distanceFromTop As Double = row + 0.5
		  Var distanceFromBottom As Double = drawHeight - distanceFromTop
		  
		  Var topLeftInset As Double = LeadingInset(distanceFromTop, topLeftRadius, topLeftStyle)
		  Var topRightInset As Double = LeadingInset(distanceFromTop, topRightRadius, topRightStyle)
		  Var bottomLeftInset As Double = LeadingInset(distanceFromBottom, bottomLeftRadius, bottomLeftStyle)
		  Var bottomRightInset As Double = LeadingInset(distanceFromBottom, bottomRightRadius, bottomRightStyle)
		  
		  leftX = MaxDouble(topLeftInset, bottomLeftInset)
		  rightX = drawWidth - MaxDouble(topRightInset, bottomRightInset)
		  
		  If rightX < leftX Then rightX = leftX
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InsetResolvedCornerRadii(insetPixels As Integer, innerWidth As Integer, innerHeight As Integer, outerTopLeftRadius As Integer, outerTopRightRadius As Integer, outerBottomLeftRadius As Integer, outerBottomRightRadius As Integer, ByRef innerTopLeftRadius As Integer, ByRef innerTopRightRadius As Integer, ByRef innerBottomLeftRadius As Integer, ByRef innerBottomRightRadius As Integer)
		  innerTopLeftRadius = MaxInteger(0, outerTopLeftRadius - insetPixels)
		  innerTopRightRadius = MaxInteger(0, outerTopRightRadius - insetPixels)
		  innerBottomLeftRadius = MaxInteger(0, outerBottomLeftRadius - insetPixels)
		  innerBottomRightRadius = MaxInteger(0, outerBottomRightRadius - insetPixels)
		  
		  NormalizeResolvedCornerRadii(innerWidth, innerHeight, innerTopLeftRadius, innerTopRightRadius, innerBottomLeftRadius, innerBottomRightRadius)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LeadingInset(distanceFromEdge As Double, radius As Integer, cornerStyle As CornerStyles) As Double
		  If radius <= 0 Then Return 0.0
		  If distanceFromEdge >= radius Then Return 0.0
		  
		  Select Case cornerStyle
		  Case CornerStyles.Bevel
		    Return radius - distanceFromEdge
		  Else
		    Var distanceToCenter As Double = radius - distanceFromEdge
		    Var chordSquared As Double = (radius * radius) - (distanceToCenter * distanceToCenter)
		    
		    If chordSquared <= 0.0 Then Return radius
		    
		    Return radius - Sqrt(chordSquared)
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MaxDouble(firstValue As Double, secondValue As Double) As Double
		  If firstValue >= secondValue Then Return firstValue
		  
		  Return secondValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MaxInteger(firstValue As Integer, secondValue As Integer) As Integer
		  If firstValue >= secondValue Then Return firstValue
		  
		  Return secondValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MinDouble(firstValue As Double, secondValue As Double) As Double
		  If firstValue <= secondValue Then Return firstValue
		  
		  Return secondValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MinInteger(firstValue As Integer, secondValue As Integer) As Integer
		  If firstValue <= secondValue Then Return firstValue
		  
		  Return secondValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub NormalizeResolvedCornerRadii(drawWidth As Integer, drawHeight As Integer, ByRef topLeftRadius As Integer, ByRef topRightRadius As Integer, ByRef bottomLeftRadius As Integer, ByRef bottomRightRadius As Integer)
		  Var scale As Double = 1.0
		  Var horizontalTopSum As Double = topLeftRadius + topRightRadius
		  Var horizontalBottomSum As Double = bottomLeftRadius + bottomRightRadius
		  Var verticalLeftSum As Double = topLeftRadius + bottomLeftRadius
		  Var verticalRightSum As Double = topRightRadius + bottomRightRadius
		  
		  If horizontalTopSum > 0.0 Then
		    scale = MinDouble(scale, drawWidth / horizontalTopSum)
		  End If
		  
		  If horizontalBottomSum > 0.0 Then
		    scale = MinDouble(scale, drawWidth / horizontalBottomSum)
		  End If
		  
		  If verticalLeftSum > 0.0 Then
		    scale = MinDouble(scale, drawHeight / verticalLeftSum)
		  End If
		  
		  If verticalRightSum > 0.0 Then
		    scale = MinDouble(scale, drawHeight / verticalRightSum)
		  End If
		  
		  scale = ClampDouble(scale, 0.0, 1.0)
		  
		  If scale < 1.0 Then
		    topLeftRadius = Round(topLeftRadius * scale)
		    topRightRadius = Round(topRightRadius * scale)
		    bottomLeftRadius = Round(bottomLeftRadius * scale)
		    bottomRightRadius = Round(bottomRightRadius * scale)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RefreshAppearance()
		  Me.Invalidate(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ResolveOuterCornerMetrics(drawWidth As Integer, drawHeight As Integer, ByRef topLeftRadius As Integer, ByRef topRightRadius As Integer, ByRef bottomLeftRadius As Integer, ByRef bottomRightRadius As Integer, ByRef topLeftStyle As CornerStyles, ByRef topRightStyle As CornerStyles, ByRef bottomLeftStyle As CornerStyles, ByRef bottomRightStyle As CornerStyles)
		  topLeftRadius = EffectiveCornerRadius(CornerTopLeftEnabled, CornerTopLeftValue, drawWidth, drawHeight)
		  topRightRadius = EffectiveCornerRadius(CornerTopRightEnabled, CornerTopRightValue, drawWidth, drawHeight)
		  bottomLeftRadius = EffectiveCornerRadius(CornerBottomLeftEnabled, CornerBottomLeftValue, drawWidth, drawHeight)
		  bottomRightRadius = EffectiveCornerRadius(CornerBottomRightEnabled, CornerBottomRightValue, drawWidth, drawHeight)
		  
		  NormalizeResolvedCornerRadii(drawWidth, drawHeight, topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius)
		  
		  topLeftStyle = EffectiveCornerStyle(CornerTopLeftEnabled, CornerTopLeftStyle)
		  topRightStyle = EffectiveCornerStyle(CornerTopRightEnabled, CornerTopRightStyle)
		  bottomLeftStyle = EffectiveCornerStyle(CornerBottomLeftEnabled, CornerBottomLeftStyle)
		  bottomRightStyle = EffectiveCornerStyle(CornerBottomRightEnabled, CornerBottomRightStyle)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetAllCorners(enabled As Boolean, cornerValue As Double, cornerStyle As CornerStyles = CornerStyles.Rounded)
		  CornerAllEnabled = enabled
		  CornerTopLeftEnabled = enabled
		  CornerTopRightEnabled = enabled
		  CornerBottomLeftEnabled = enabled
		  CornerBottomRightEnabled = enabled
		  
		  CornerTopLeftValue = cornerValue
		  CornerTopRightValue = cornerValue
		  CornerBottomLeftValue = cornerValue
		  CornerBottomRightValue = cornerValue
		  
		  CornerTopLeftStyle = cornerStyle
		  CornerTopRightStyle = cornerStyle
		  CornerBottomLeftStyle = cornerStyle
		  CornerBottomRightStyle = cornerStyle
		  
		  RefreshAppearance
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		BorderEnabled As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		BorderThickness As Double = 1.0
	#tag EndProperty

	#tag Property, Flags = &h0
		BorderColor As Color = &c000000
	#tag EndProperty

	#tag Property, Flags = &h0
		FillColor As Color = &cFFFFFF00
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerAllEnabled As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerUnit As CornerUnits = CornerUnits.Pixels
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerTopLeftEnabled As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerTopLeftStyle As CornerStyles = CornerStyles.Rounded
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerTopLeftValue As Double = 0.0
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerTopRightEnabled As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerTopRightStyle As CornerStyles = CornerStyles.Rounded
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerTopRightValue As Double = 0.0
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerBottomLeftEnabled As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerBottomLeftStyle As CornerStyles = CornerStyles.Rounded
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerBottomLeftValue As Double = 0.0
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerBottomRightEnabled As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerBottomRightStyle As CornerStyles = CornerStyles.Rounded
	#tag EndProperty

	#tag Property, Flags = &h0
		CornerBottomRightValue As Double = 0.0
	#tag EndProperty


	#tag Enum, Name = CornerStyles, Type = Integer, Flags = &h0
		Rounded = 0
		Bevel = 1
	#tag EndEnum

	#tag Enum, Name = CornerUnits, Type = Integer, Flags = &h0
		Pixels = 0
		Percent = 1
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Behavior"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockHorizontal"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockVertical"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Behavior"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderEnabled"
			Visible=true
			Group="Border"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderThickness"
			Visible=true
			Group="Border"
			InitialValue="1.0"
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderColor"
			Visible=true
			Group="Border"
			InitialValue="&c000000"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FillColor"
			Visible=true
			Group="Fill"
			InitialValue="&cFFFFFF00"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerAllEnabled"
			Visible=true
			Group="Corner"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerUnit"
			Visible=true
			Group="Corner"
			InitialValue="0"
			Type="CornerUnits"
			EditorType="Enum"
			#tag EnumValues
				"0 - Pixels"
				"1 - Percent"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerTopLeftEnabled"
			Visible=true
			Group="Corner"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerTopLeftStyle"
			Visible=true
			Group="Corner"
			InitialValue="0"
			Type="CornerStyles"
			EditorType="Enum"
			#tag EnumValues
				"0 - Rounded"
				"1 - Bevel"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerTopLeftValue"
			Visible=true
			Group="Corner"
			InitialValue="0.0"
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerTopRightEnabled"
			Visible=true
			Group="Corner"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerTopRightStyle"
			Visible=true
			Group="Corner"
			InitialValue="0"
			Type="CornerStyles"
			EditorType="Enum"
			#tag EnumValues
				"0 - Rounded"
				"1 - Bevel"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerTopRightValue"
			Visible=true
			Group="Corner"
			InitialValue="0.0"
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerBottomLeftEnabled"
			Visible=true
			Group="Corner"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerBottomLeftStyle"
			Visible=true
			Group="Corner"
			InitialValue="0"
			Type="CornerStyles"
			EditorType="Enum"
			#tag EnumValues
				"0 - Rounded"
				"1 - Bevel"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerBottomLeftValue"
			Visible=true
			Group="Corner"
			InitialValue="0.0"
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerBottomRightEnabled"
			Visible=true
			Group="Corner"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerBottomRightStyle"
			Visible=true
			Group="Corner"
			InitialValue="0"
			Type="CornerStyles"
			EditorType="Enum"
			#tag EnumValues
				"0 - Rounded"
				"1 - Bevel"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="CornerBottomRightValue"
			Visible=true
			Group="Corner"
			InitialValue="0.0"
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DiffEngineDisabled"
			Visible=false
			Group="Canvas"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mPanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Indicator"
			Visible=false
			Group="Visual Controls"
			InitialValue=""
			Type="WebUIControl.Indicators"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Primary"
				"2 - Secondary"
				"3 - Success"
				"4 - Danger"
				"5 - Warning"
				"6 - Info"
				"7 - Light"
				"8 - Dark"
				"9 - Link"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="ControlID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
