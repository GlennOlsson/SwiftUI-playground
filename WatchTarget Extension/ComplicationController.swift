//
//  ComplicationController.swift
//  WatchTarget Extension
//
//  Created by Glenn Olsson on 2020-05-28.
//  Copyright © 2020 Glenn Olsson. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
	
	// MARK: - Timeline Configuration
	
	func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
		handler([.forward, .backward])
	}
	
	func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		handler(nil)
	}
	
	func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		handler(nil)
	}
	
	func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
		handler(.showOnLockScreen)
	}
	
	// MARK: - Timeline Population
	
	func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
		// Call the handler with the current timeline entry
		
		var finalTemplate: CLKComplicationTemplate!
		
		switch complication.family {
		case .graphicCircular:
			let template = CLKComplicationTemplateGraphicCircularStackText()
			template.line1TextProvider = CLKTextProvider(format: "HELLO; WORLD!")
			template.line2TextProvider = CLKTextProvider(format: "🍆")
			finalTemplate = template
	
		case .circularSmall:
			let template = CLKComplicationTemplateCircularSmallRingText()
			template.fillFraction = 0.5
			template.ringStyle = .open
			template.textProvider = CLKTextProvider(format: "OK")
			finalTemplate = template
			
		case .modularLarge:
			let template = CLKComplicationTemplateModularLargeStandardBody()
			template.headerTextProvider = CLKTextProvider(format: "Lilla söta fröken")
			template.headerImageProvider = CLKImageProvider(onePieceImage: UIImage(systemName: "moon")!)
			template.body1TextProvider = CLKTextProvider(format: "Text1")
			template.body2TextProvider = CLKTextProvider(format: "Text2 som säger såhär")
			finalTemplate = template
			
			print("Modular large")
			
		case .modularSmall:
			let template = CLKComplicationTemplateModularSmallStackImage()
			template.line2TextProvider = CLKTextProvider(format: "Lilla söta fröken")
			template.line1ImageProvider = CLKImageProvider(onePieceImage: UIImage(systemName: "moon")!)
			finalTemplate = template
			
		case .graphicRectangular:
			let template = CLKComplicationTemplateGraphicRectangularStandardBody()
			template.headerTextProvider = CLKTextProvider(format: "Lilla söta fröken")
			template.headerImageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(systemName: "flame")!, tintedImageProvider: CLKImageProvider(onePieceImage: UIImage(systemName: "pencil.and.outline")!))
			template.body1TextProvider = CLKTextProvider(format: "Text1")
//			template.body2TextProvider = CLKTextProvider(format: "Text2 som säger såhär")
			finalTemplate = template
			
		case .utilitarianSmall:
			let template = CLKComplicationTemplateUtilitarianSmallRingText()
			template.fillFraction = 0.3
			template.ringStyle = .closed
			template.textProvider = CLKTextProvider(format: "BAJS")
			finalTemplate = template
			
		default:
			handler(nil)
			return
		}

		let clk = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: finalTemplate)
		handler(clk)
	}
	
	func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
		// Call the handler with the timeline entries prior to the given date
		handler(nil)
	}
	
	func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
		// Call the handler with the timeline entries after to the given date
		handler(nil)
	}
	
	// MARK: - Placeholder Templates
	
	func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
		// This method will be called once per supported complication, and the results will be cached
		handler(nil)
	}
	
}
