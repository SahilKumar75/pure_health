"""
Report Generator Service
Generates PDF and Excel reports for water quality analysis
"""

from reportlab.lib.pagesizes import A4, letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image, PageBreak
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
from datetime import datetime
import pandas as pd
import numpy as np
from typing import Dict, List, Any
import os
import io
import matplotlib
matplotlib.use('Agg')  # Use non-GUI backend
import matplotlib.pyplot as plt


class ReportGenerator:
    """Generate professional PDF and Excel reports"""
    
    def __init__(self):
        self.styles = getSampleStyleSheet()
        self._setup_custom_styles()
        
    def _setup_custom_styles(self):
        """Setup custom paragraph styles"""
        self.title_style = ParagraphStyle(
            'CustomTitle',
            parent=self.styles['Heading1'],
            fontSize=24,
            textColor=colors.HexColor('#1e3a8a'),
            spaceAfter=30,
            alignment=TA_CENTER,
            fontName='Helvetica-Bold'
        )
        
        self.heading_style = ParagraphStyle(
            'CustomHeading',
            parent=self.styles['Heading2'],
            fontSize=16,
            textColor=colors.HexColor('#1e3a8a'),
            spaceAfter=12,
            spaceBefore=12,
            fontName='Helvetica-Bold'
        )
        
        self.subheading_style = ParagraphStyle(
            'CustomSubheading',
            parent=self.styles['Heading3'],
            fontSize=12,
            textColor=colors.HexColor('#374151'),
            spaceAfter=8,
            fontName='Helvetica-Bold'
        )
    
    def generate_comprehensive_report(
        self,
        analysis_data: Dict[str, Any],
        output_path: str
    ) -> str:
        """Generate comprehensive PDF report with all analysis components"""
        
        doc = SimpleDocTemplate(output_path, pagesize=A4,
                                rightMargin=72, leftMargin=72,
                                topMargin=72, bottomMargin=18)
        story = []
        
        # Cover Page
        story.extend(self._generate_cover_page(analysis_data))
        story.append(PageBreak())
        
        # Executive Summary
        story.extend(self._generate_executive_summary(analysis_data))
        story.append(Spacer(1, 0.3*inch))
        
        # Risk Assessment Section
        if 'riskAssessment' in analysis_data:
            story.extend(self._generate_risk_section(analysis_data['riskAssessment']))
            story.append(Spacer(1, 0.3*inch))
        
        # Predictions Section
        if 'predictions' in analysis_data:
            story.extend(self._generate_predictions_section(analysis_data['predictions']))
            story.append(Spacer(1, 0.3*inch))
        
        # Trend Analysis Section
        if 'trendAnalysis' in analysis_data:
            story.extend(self._generate_trends_section(analysis_data['trendAnalysis']))
            story.append(Spacer(1, 0.3*inch))
        
        # Recommendations Section
        if 'recommendations' in analysis_data:
            story.extend(self._generate_recommendations_section(analysis_data['recommendations']))
        
        # Footer
        story.append(Spacer(1, 0.5*inch))
        story.extend(self._generate_footer())
        
        # Build PDF
        doc.build(story)
        return output_path
    
    def _generate_cover_page(self, data: Dict[str, Any]) -> List:
        """Generate report cover page"""
        elements = []
        
        # Title
        elements.append(Spacer(1, 2*inch))
        elements.append(Paragraph(
            "Water Quality Analysis Report",
            self.title_style
        ))
        elements.append(Spacer(1, 0.5*inch))
        
        # Subtitle
        subtitle_style = ParagraphStyle(
            'Subtitle',
            parent=self.styles['Normal'],
            fontSize=14,
            textColor=colors.HexColor('#6b7280'),
            alignment=TA_CENTER
        )
        elements.append(Paragraph(
            "Maharashtra Water Quality Monitoring System",
            subtitle_style
        ))
        elements.append(Spacer(1, 1*inch))
        
        # Report Info
        info_data = [
            ['Report ID:', data.get('id', 'N/A')[:20]],
            ['Generated:', datetime.now().strftime('%B %d, %Y at %I:%M %p')],
            ['Location:', data.get('location', {}).get('name', 'Multiple Stations')],
            ['File Analyzed:', data.get('fileName', 'N/A')],
        ]
        
        info_table = Table(info_data, colWidths=[2*inch, 4*inch])
        info_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 11),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ]))
        elements.append(info_table)
        
        return elements
    
    def _generate_executive_summary(self, data: Dict[str, Any]) -> List:
        """Generate executive summary section"""
        elements = []
        
        elements.append(Paragraph("Executive Summary", self.heading_style))
        
        # Get key metrics
        risk = data.get('riskAssessment', {})
        trends = data.get('trendAnalysis', {})
        
        summary_text = f"""
        This report provides a comprehensive analysis of water quality parameters based on uploaded data.
        The analysis includes 60-day predictions, risk assessment, trend analysis, and actionable recommendations.
        <br/><br/>
        <b>Overall Risk Level:</b> {risk.get('overallRiskLevel', 'N/A').upper()}<br/>
        <b>Risk Score:</b> {risk.get('riskScore', 0)}/100<br/>
        <b>Trend:</b> {trends.get('overallTrend', 'N/A').title()}<br/>
        <b>Critical Factors:</b> {len([f for f in risk.get('riskFactors', []) if f.get('level') == 'critical'])}
        """
        
        elements.append(Paragraph(summary_text, self.styles['BodyText']))
        
        return elements
    
    def _generate_risk_section(self, risk_data: Dict[str, Any]) -> List:
        """Generate risk assessment section"""
        elements = []
        
        elements.append(Paragraph("Risk Assessment", self.heading_style))
        
        # Risk summary
        summary = risk_data.get('summary', '')
        elements.append(Paragraph(summary.replace('\n', '<br/>'), self.styles['BodyText']))
        elements.append(Spacer(1, 0.2*inch))
        
        # Risk factors table
        factors = risk_data.get('riskFactors', [])
        if factors:
            elements.append(Paragraph("Risk Factors", self.subheading_style))
            
            table_data = [['Parameter', 'Level', 'Score', 'Current Value', 'Description']]
            for factor in factors[:10]:  # Top 10 factors
                # Handle both riskScore and risk_score field names for flexibility
                risk_score = factor.get('riskScore', factor.get('risk_score', 0))
                current_val = factor.get('currentValue', factor.get('current_value', 0))
                
                table_data.append([
                    factor.get('parameter', 'Unknown'),
                    factor.get('level', 'unknown').upper(),
                    f"{risk_score:.1f}",
                    f"{current_val:.2f}",
                    factor.get('description', '')[:40] + '...' if len(factor.get('description', '')) > 40 else factor.get('description', '')
                ])
            
            table = Table(table_data, colWidths=[1.2*inch, 0.8*inch, 0.6*inch, 0.9*inch, 2.5*inch])
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1e3a8a')),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 10),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('GRID', (0, 0), (-1, -1), 1, colors.black),
                ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#f0f9ff')]),
                ('FONTSIZE', (0, 1), (-1, -1), 8),
            ]))
            elements.append(table)
        
        return elements
    
    def _generate_predictions_section(self, predictions: Dict[str, Any]) -> List:
        """Generate predictions section"""
        elements = []
        
        elements.append(Paragraph("60-Day Predictions", self.heading_style))
        
        # Predictions summary
        summary_text = f"""
        AI-powered predictions for the next 60 days (8 weeks) show trends for all monitored parameters.
        Predictions are based on historical data patterns and statistical modeling.
        """
        elements.append(Paragraph(summary_text, self.styles['BodyText']))
        elements.append(Spacer(1, 0.2*inch))
        
        # Predictions table
        if predictions:
            table_data = [['Parameter', 'Current', 'Week 4', 'Week 8', 'Trend', 'Confidence']]
            
            for param, pred in list(predictions.items())[:8]:  # Top 8 parameters
                week4_val = pred['predicted'][3] if len(pred['predicted']) > 3 else 'N/A'
                week8_val = pred['predicted'][7] if len(pred['predicted']) > 7 else 'N/A'
                avg_conf = np.mean(pred.get('confidence', [0.85])) * 100
                
                table_data.append([
                    param,
                    f"{pred['current']:.2f}",
                    f"{week4_val:.2f}" if isinstance(week4_val, (int, float)) else week4_val,
                    f"{week8_val:.2f}" if isinstance(week8_val, (int, float)) else week8_val,
                    pred['trend'].title(),
                    f"{avg_conf:.0f}%"
                ])
            
            table = Table(table_data, colWidths=[1.5*inch, 0.8*inch, 0.8*inch, 0.8*inch, 1*inch, 0.8*inch])
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#10b981')),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 10),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('GRID', (0, 0), (-1, -1), 1, colors.black),
                ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#ecfdf5')]),
            ]))
            elements.append(table)
        
        return elements
    
    def _generate_trends_section(self, trends_data: Dict[str, Any]) -> List:
        """Generate trend analysis section"""
        elements = []
        
        elements.append(Paragraph("Trend Analysis", self.heading_style))
        
        # Trends summary
        summary = trends_data.get('summary', '')
        elements.append(Paragraph(summary.replace('\n', '<br/>'), self.styles['BodyText']))
        elements.append(Spacer(1, 0.2*inch))
        
        # Statistics
        stats = trends_data.get('statistics', {})
        if stats:
            stats_text = f"""
            <b>Parameters Improving:</b> {stats.get('improving', 0)}<br/>
            <b>Parameters Declining:</b> {stats.get('declining', 0)}<br/>
            <b>Parameters Stable:</b> {stats.get('stable', 0)}<br/>
            <b>Total Parameters Analyzed:</b> {stats.get('totalParameters', 0)}
            """
            elements.append(Paragraph(stats_text, self.styles['BodyText']))
        
        return elements
    
    def _generate_recommendations_section(self, recommendations: List[Dict[str, Any]]) -> List:
        """Generate recommendations section"""
        elements = []
        
        elements.append(Paragraph("Recommendations", self.heading_style))
        
        # Group by priority (with safe access)
        high_priority = [r for r in recommendations if r.get('priority', '') == 'high']
        medium_priority = [r for r in recommendations if r.get('priority', '') == 'medium']
        
        # High priority recommendations
        if high_priority:
            elements.append(Paragraph("High Priority Actions", self.subheading_style))
            for i, rec in enumerate(high_priority, 1):
                rec_text = f"""
                <b>{i}. {rec.get('title', 'Untitled')}</b><br/>
                <i>Category: {rec.get('category', 'general').title()}</i><br/>
                {rec.get('description', '')}<br/>
                <b>Timeframe:</b> {rec.get('timeframe', 'short-term').title()}<br/>
                """
                elements.append(Paragraph(rec_text, self.styles['BodyText']))
                elements.append(Spacer(1, 0.1*inch))
        
        # Medium priority recommendations
        if medium_priority:
            elements.append(Spacer(1, 0.2*inch))
            elements.append(Paragraph("Medium Priority Actions", self.subheading_style))
            for i, rec in enumerate(medium_priority, 1):
                desc = rec.get('description', '')
                rec_text = f"""
                <b>{i}. {rec.get('title', 'Untitled')}</b> - {desc[:100]}{'...' if len(desc) > 100 else ''}
                """
                elements.append(Paragraph(rec_text, self.styles['BodyText']))
                elements.append(Spacer(1, 0.05*inch))
        
        return elements
    
    def _generate_footer(self) -> List:
        """Generate report footer"""
        elements = []
        
        footer_style = ParagraphStyle(
            'Footer',
            parent=self.styles['Normal'],
            fontSize=9,
            textColor=colors.HexColor('#6b7280'),
            alignment=TA_CENTER
        )
        
        footer_text = f"""
        Generated by PureHealth AI System | Maharashtra Water Quality Monitoring<br/>
        {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}<br/>
        <i>This report is computer-generated and does not require a signature.</i>
        """
        elements.append(Paragraph(footer_text, footer_style))
        
        return elements
