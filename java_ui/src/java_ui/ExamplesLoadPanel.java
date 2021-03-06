package java_ui;

import javax.swing.JPanel;
import javax.swing.JLabel;
import javax.swing.JButton;
import java.awt.GridBagLayout;
import java.awt.GridBagConstraints;
import java.awt.Insets;
import javax.swing.JSeparator;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.awt.event.ActionEvent;
import java.awt.BorderLayout;
import javax.swing.JRadioButton;
import javax.swing.ButtonGroup;

public class ExamplesLoadPanel extends JPanel {
	private final ButtonGroup buttonGroup1 = new ButtonGroup();
	private final ButtonGroup buttonGroup2 = new ButtonGroup();
	
	private int example_number;
	private String example_preferences;
	
	public ExamplesLoadPanel(AllStepsPanel stepsPanel) {
		setLayout(new BorderLayout(0, 0));
		
		JPanel container = new JPanel();
		GridBagLayout gbc_container = new GridBagLayout();
		gbc_container.columnWidths = new int[]{0, 66, 118, 95, 0};
		gbc_container.rowHeights = new int[]{37, 39, 0, 0};
		gbc_container.columnWeights = new double[]{};
		gbc_container.rowWeights = new double[]{};
		add(container, BorderLayout.CENTER);
		GridBagLayout gbl_container = new GridBagLayout();
		gbl_container.columnWidths = new int[]{70, 79, 84, 0};
		gbl_container.rowHeights = new int[]{25, 0, 25, 0};
		gbl_container.columnWeights = new double[]{1.0, 1.0, 1.0, Double.MIN_VALUE};
		gbl_container.rowWeights = new double[]{0.0, 0.0, 1.0, Double.MIN_VALUE};
		container.setLayout(gbl_container);
		
		JLabel instructionLabel = new JLabel("Click on the buttons to load any example.");
		GridBagConstraints gbc_instructionLabel = new GridBagConstraints();
		gbc_instructionLabel.gridy = 0;
		gbc_instructionLabel.insets = new Insets(5, 5, 5, 0);
		gbc_instructionLabel.anchor = GridBagConstraints.WEST;
		gbc_instructionLabel.gridwidth = 3;
		gbc_instructionLabel.gridx = 0;
		container.add(instructionLabel, gbc_instructionLabel);
		
		JRadioButton example1RadioBtn = new JRadioButton("Evidence Set 1");
		example1RadioBtn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				example_number = 1;
				stepsPanel.cleanSteps();
			}
		});
		buttonGroup1.add(example1RadioBtn);
		GridBagConstraints gbc_example1RadioBtn = new GridBagConstraints();
		gbc_example1RadioBtn.anchor = GridBagConstraints.NORTHWEST;
		gbc_example1RadioBtn.insets = new Insets(0, 5, 5, 5);
		gbc_example1RadioBtn.gridx = 0;
		gbc_example1RadioBtn.gridy = 1;
		container.add(example1RadioBtn, gbc_example1RadioBtn);
		
		JRadioButton example2RadioBtn = new JRadioButton("Evidence Set 2");
		example2RadioBtn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				example_number = 2;
				stepsPanel.cleanSteps();
			}
		});
		buttonGroup1.add(example2RadioBtn);
		GridBagConstraints gbc_example2RadioBtn = new GridBagConstraints();
		gbc_example2RadioBtn.anchor = GridBagConstraints.NORTHWEST;
		gbc_example2RadioBtn.insets = new Insets(0, 0, 5, 5);
		gbc_example2RadioBtn.gridx = 1;
		gbc_example2RadioBtn.gridy = 1;
		container.add(example2RadioBtn, gbc_example2RadioBtn);
		
		JButton loadButton = new JButton("Load Example");
		loadButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
					stepsPanel.loadExample(example_number, example_preferences);
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
		});
		GridBagConstraints gbc_loadButton = new GridBagConstraints();
		gbc_loadButton.anchor = GridBagConstraints.NORTHWEST;
		gbc_loadButton.insets = new Insets(0, 0, 5, 0);
		gbc_loadButton.gridx = 2;
		gbc_loadButton.gridy = 1;
		container.add(loadButton, gbc_loadButton);
		
		JRadioButton timButton = new JRadioButton("Tim's Preferences");
		buttonGroup2.add(timButton);
		GridBagConstraints gbc_timButton = new GridBagConstraints();
		gbc_timButton.anchor = GridBagConstraints.NORTHWEST;
		gbc_timButton.insets = new Insets(5, 5, 0, 5);
		gbc_timButton.gridx = 0;
		gbc_timButton.gridy = 2;
		container.add(timButton, gbc_timButton);
		timButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				example_preferences = "Tim";
				stepsPanel.cleanSteps();
			}
		});
		
		JRadioButton augustButton = new JRadioButton("August's Preferences");
		buttonGroup2.add(augustButton);
		GridBagConstraints gbc_augustButton = new GridBagConstraints();
		gbc_augustButton.anchor = GridBagConstraints.NORTHWEST;
		gbc_augustButton.insets = new Insets(5, 0, 0, 5);
		gbc_augustButton.gridx = 1;
		gbc_augustButton.gridy = 2;
		container.add(augustButton, gbc_augustButton);
		augustButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				example_preferences = "August";
				stepsPanel.cleanSteps();
			}
		});
		
		JRadioButton kateButton = new JRadioButton("Kate's Preferences");
		buttonGroup2.add(kateButton);
		GridBagConstraints gbc_kateButton = new GridBagConstraints();
		gbc_kateButton.insets = new Insets(5, 0, 0, 0);
		gbc_kateButton.anchor = GridBagConstraints.NORTHWEST;
		gbc_kateButton.gridx = 2;
		gbc_kateButton.gridy = 2;
		container.add(kateButton, gbc_kateButton);
		kateButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				example_preferences = "Kate";
				stepsPanel.cleanSteps();
			}
		});
		
		JSeparator separator = new JSeparator();
		add(separator, BorderLayout.SOUTH);
		
		example1RadioBtn.doClick();
		timButton.doClick();
	
	}

}
