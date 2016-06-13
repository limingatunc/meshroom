import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import DarkStyle.Controls 1.0
import DarkStyle 1.0
import NodeEditor 1.0
import ImageGallery 1.0

Rectangle {

    id : root

    // properties
    property variant model: null
    color: Style.window.color.normal
    clip: true

    // signal / slots
    onModelChanged: stackView.pop()

    // attribute delegates
    Component {
        id: emptyDelegate
        Item {}
    }
    Component {
        id: listDelegate
        RowLayout {
            Text {
                text: modelData ? modelData.value.length + " items" : "0 item"
                font.pixelSize: Style.text.size.xsmall
            }
            Item { Layout.fillWidth: true } // spacer
            ToolButton {
                iconSource: "qrc:///images/arrow.svg"
                onClicked: stackView.push({
                    item: galleryTab,
                    properties: {
                        attribute: modelData,
                        model: modelData.value
                    }
                })
            }
        }
    }
    Component {
        id: labelDelegate
        Text {
            text: modelData.name
            font.pixelSize: Style.text.size.xsmall
        }
    }
    Component {
        id: sliderDelegate
        Slider {
            Component.onCompleted: {
                minimumValue = modelData.min;
                maximumValue = modelData.max;
                stepSize = modelData.step;
                value = modelData.value;
            }
            updateValueWhileDragging: true
            onValueChanged: modelData.value = value
        }
    }
    Component {
        id: textfieldDelegate
        TextField {
            text: modelData.value
            onEditingFinished: modelData.value = text
        }
    }
    Component {
        id: comboboxDelegate
        ComboBox {
            Component.onCompleted: currentIndex = find(modelData.value)
            model: modelData.options
            onActivated: modelData.value = textAt(index)
        }
    }
    Component {
        id: checkboxDelegate
        CheckBox {
            Component.onCompleted: checked = modelData.value
            onClicked: modelData.value = checked
        }
    }

    // stack view components
    Component {
        id: mainPropertiesTab
        ScrollView {
            id: scrollView
            flickableItem.anchors.margins: 5
            GridLayout {
                width: scrollView.width - 10
                columns: 2
                rowSpacing: 10
                columnSpacing: 5
                Repeater {
                    model: root.model ? root.model.inputs.count*2 : 0
                    delegate: Loader {
                        Layout.fillWidth: index%2 != 0
                        Layout.preferredWidth: index%2 ? parent.width : parent.width*0.3
                        property variant modelData: root.model.inputs.get(index/2).modelData
                        sourceComponent: {
                            if(index % 2 == 0)
                                return labelDelegate;
                            switch(modelData.type) {
                                case Attribute.UNKNOWN: return emptyDelegate
                                case Attribute.TEXTFIELD: return textfieldDelegate
                                case Attribute.SLIDER: return sliderDelegate
                                case Attribute.COMBOBOX: return comboboxDelegate
                                case Attribute.CHECKBOX: return checkboxDelegate
                                case Attribute.IMAGELIST: return listDelegate
                            }
                        }
                    }
                }
            }
        }
    }
    Component {
        id: galleryTab
        Gallery {
            property variant attribute: null
            closeable: true
            onClosed: stackView.pop()
            onItemAdded: {
                var values = attribute.value;
                values.push(item);
                attribute.value = values;
                model = attribute.value;
            }
        }
    }

    // stack view
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPropertiesTab
    }
}
