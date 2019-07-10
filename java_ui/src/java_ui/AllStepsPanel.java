package java_ui;

import javax.swing.JPanel;
import java.awt.BorderLayout;
import javax.swing.JSeparator;
import javax.swing.table.TableModel;

import java_ui.prolog_loader.CPrefRulesPrologLoader;
import java_ui.prolog_loader.CriteriaPrologLoader;
import java_ui.prolog_loader.EvidencePrologLoader;
import java_ui.steps.DefineCprefRulesStepPanel;
import java_ui.steps.DefineEvidenceStepPanel;
import java_ui.steps.DefineStepPanel;
import java_ui.steps.ResultsPanel;
import java_ui.steps.RunStepPanel;
import java_ui.steps.StepPanel;
import java_ui.table_editor.model_builder.RulesTableModelBuilder;
import java_ui.table_editor.model_builder.CriteriaTableModelBuilder;
import java_ui.table_editor.model_builder.EvidenceTableModelBuilder;
import java_ui.table_editor.panel.CPrefRulesTableEditorPanel;
import java_ui.table_editor.panel.CriteriaTableEditorPanel;
import java_ui.table_editor.panel.EvidenceTableEditorPanel;
import java_ui.table_editor.table_reader.CSVTableReader;

import java.awt.GridBagLayout;
import java.awt.GridBagConstraints;
import java.awt.Insets;
import java.io.File;
import java.io.IOException;

public class AllStepsPanel extends JPanel{
	
	StepPanel step_1, step_2, step_3, step_4, step_5;
	RunStepPanel run_step;
	
	public AllStepsPanel(ResultsPanel resultsPanel) throws IOException{
		super();
		setLayout(new BorderLayout(0, 0));
		
		JPanel stepsPanel = new JPanel();
		add(stepsPanel);
		GridBagLayout gbl_stepsPanel = new GridBagLayout();
		gbl_stepsPanel.columnWidths = new int[]{313, 0};
		gbl_stepsPanel.rowHeights = new int[]{80, 80, 0, 0, 0};
		gbl_stepsPanel.columnWeights = new double[]{1.0, Double.MIN_VALUE};
		gbl_stepsPanel.rowWeights = new double[]{1.0, 1.0, 1.0, 0.0, Double.MIN_VALUE};
		stepsPanel.setLayout(gbl_stepsPanel);
		
		
		
		JPanel examplesLoadPanel = new ExamplesLoadPanel(this);
		GridBagConstraints gbc_examplesLoadPanel = new GridBagConstraints();
		gbc_examplesLoadPanel.fill = GridBagConstraints.BOTH;
		gbc_examplesLoadPanel.insets = new Insets(0, 0, 5, 0);
		gbc_examplesLoadPanel.gridx = 0;
		gbc_examplesLoadPanel.gridy = 0;
		stepsPanel.add(examplesLoadPanel, gbc_examplesLoadPanel);
		
		
		step_1 = new DefineStepPanel(
				"1. Define the set of criteria.",
				"Criteria",
				new CriteriaTableEditorPanel(),
				new CriteriaPrologLoader()
		);
		
		step_2 = new DefineEvidenceStepPanel(
				"2. Define the set of evidence.",
				"Evidence",
				new EvidenceTableEditorPanel(),
				new EvidencePrologLoader()
		);
		
		step_3 = new DefineCprefRulesStepPanel(
				"3. Define the set of CPref-Rules.",
				"CPref-Rules",
				new CPrefRulesTableEditorPanel(),
				new CPrefRulesPrologLoader()
		);
		
		run_step = new RunStepPanel(step_1, resultsPanel);
		
		
		step_1.setFollowingStep(step_2);
		step_2.setFollowingStep(step_3);
		step_3.setFollowingStep(run_step);
		
		step_2.disableStep();
		
		StepPanel [] stepsPanels = {step_1, step_2, step_3};
		
		int i;
		GridBagConstraints gbc_container;
		
		for(i = 0; i < stepsPanels.length; i++) {
			JPanel container = new JPanel();
			gbc_container = new GridBagConstraints();
			gbc_container.fill = GridBagConstraints.BOTH;
			gbc_container.insets = new Insets(0, 0, 5, 0);
			gbc_container.gridx = 0;
			gbc_container.gridy = i+1;
			stepsPanel.add(container, gbc_container);
			container.setLayout(new BorderLayout(0, 0));
			
			container.add(stepsPanels[i], BorderLayout.CENTER);
			container.add(new JSeparator(), BorderLayout.SOUTH);
			
		}
		
		GridBagConstraints gbc_lastPanel = new GridBagConstraints();
		gbc_lastPanel.fill = GridBagConstraints.BOTH;
		gbc_lastPanel.insets = new Insets(0, 0, 5, 0);
		gbc_lastPanel.gridx = 0;
		gbc_lastPanel.gridy = i+1;
		stepsPanel.add(run_step, gbc_lastPanel);
	
	}
	
	
	public void loadExample(int n, String subject) throws IOException{
		
		String criteria_example_path = "criteria_example.csv";
		String evidence_example_path = "evidence_example_"+n+".csv";
		String cpref_rules_example_path = "cpref_rules_example ("+subject+").csv";
		
		File criteria_file = new File(DSJavaUI.getExamplesFolderRelativePath()+"/examples/"+criteria_example_path);
		File evidence_file = new File(DSJavaUI.getExamplesFolderRelativePath()+"/examples/"+evidence_example_path);
		File cpref_rules_file = new File(DSJavaUI.getExamplesFolderRelativePath()+"/examples/"+cpref_rules_example_path);
		
		TableModel criteriaModel = new CriteriaTableModelBuilder(new CSVTableReader(criteria_file)).getTableModel();
		TableModel evidenceModel = new EvidenceTableModelBuilder(new CSVTableReader(evidence_file)).getTableModel();
		TableModel cprefRulesModel = new RulesTableModelBuilder(new CSVTableReader(cpref_rules_file)).getTableModel();
		
		((DefineStepPanel)step_1).setTableModel(criteriaModel);
		((DefineEvidenceStepPanel) step_2).setTableModel(evidenceModel);		
		((DefineStepPanel)step_3).setTableModel(cprefRulesModel);
		
		
		run_step.enableStep();
		
	}
	
	public void cleanSteps(){
		if(this.step_1 != null){
			this.step_1.cleanStep();
		}
	}
	
}
