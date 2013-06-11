-----------------------------------------------------------------------------
-- |
-- Module      :  Graphics.Rendering.Chart.Plot.FillBetween
-- Copyright   :  (c) Tim Docker 2006
-- License     :  BSD-style (see chart/COPYRIGHT)
--
-- Plots that fill the area between two lines.
--
{-# OPTIONS_GHC -XTemplateHaskell #-}

module Graphics.Rendering.Chart.Plot.FillBetween(
    PlotFillBetween(..),
    defaultPlotFillBetween,

    -- * Accessors
    -- | These accessors are generated by template haskell
    plot_fillbetween_title,
    plot_fillbetween_style,
    plot_fillbetween_values,
) where

import Data.Accessor.Template
import Graphics.Rendering.Chart.Geometry
import Graphics.Rendering.Chart.Drawing
import Graphics.Rendering.Chart.Renderable
import Graphics.Rendering.Chart.Plot.Types
import Data.Colour (opaque)
import Data.Colour.Names (black, blue)
import Data.Colour.SRGB (sRGB)

-- | Value specifying a plot filling the area between two sets of Y
--   coordinates, given common X coordinates.

data PlotFillBetween x y = PlotFillBetween {
    plot_fillbetween_title_  :: String,
    plot_fillbetween_style_  :: FillStyle,
    plot_fillbetween_values_ :: [ (x, (y,y))]
}


instance ToPlot PlotFillBetween where
    toPlot p = Plot {
        plot_render_     = renderPlotFillBetween p,
        plot_legend_     = [(plot_fillbetween_title_ p,renderPlotLegendFill p)],
        plot_all_points_ = plotAllPointsFillBetween p
    }

renderPlotFillBetween :: (ChartBackend m) => PlotFillBetween x y -> PointMapFn x y -> m ()
renderPlotFillBetween p pmap =
    renderPlotFillBetween' p (plot_fillbetween_values_ p) pmap

renderPlotFillBetween' p [] _     = return ()
renderPlotFillBetween' p vs pmap  = bLocal $ do
    bSetFillStyle (plot_fillbetween_style_ p)
    fillPath ([p0] ++ p1s ++ reverse p2s ++ [p0])
  where
    pmap'    = mapXY pmap
    (p0:p1s) = map pmap' [ (x,y1) | (x,(y1,y2)) <- vs ]
    p2s      = map pmap' [ (x,y2) | (x,(y1,y2)) <- vs ]

renderPlotLegendFill :: (ChartBackend m) => PlotFillBetween x y -> Rect -> m ()
renderPlotLegendFill p r = bLocal $ do
    bSetFillStyle (plot_fillbetween_style_ p)
    fillPath (rectPath r)

plotAllPointsFillBetween :: PlotFillBetween x y -> ([x],[y])
plotAllPointsFillBetween p = ( [ x | (x,(_,_)) <- pts ]
                             , concat [ [y1,y2] | (_,(y1,y2)) <- pts ] )
  where
    pts = plot_fillbetween_values_ p


defaultPlotFillBetween :: PlotFillBetween x y
defaultPlotFillBetween = PlotFillBetween {
    plot_fillbetween_title_  = "",
    plot_fillbetween_style_  = solidFillStyle (opaque $ sRGB 0.5 0.5 1.0),
    plot_fillbetween_values_ = []
}

----------------------------------------------------------------------
-- Template haskell to derive an instance of Data.Accessor.Accessor
-- for each field.

$( deriveAccessors ''PlotFillBetween )
