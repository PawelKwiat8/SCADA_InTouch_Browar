
## Technologie
- InTouch
- MatriconOPC.Simulation
- Matlab, Simulink

## **Opis Projektu: Wizualizacja SCADA dla Procesu Browarniczego**

W ramach projektu stworzono system wizualizacji SCADA w oprogramowaniu **AVEVA InTouch**. System ten został zintegrowany z gotowym modelem dynamicznym procesu browarniczego, działającym w środowisku **Simulink**.

Połączenie między wizualizacją a symulatorem zrealizowano za pomocą standardu **OPC**. System InTouch skonfigurowano jako **klienta OPC**, który komunikował się z **serwerem OPC** udostępnianym przez symulację w Simulinku. Umożliwiło to dwukierunkową wymianę danych: odczyt wartości procesowych z symulatora i wysyłanie do niego poleceń sterujących.

**W ramach prac zrealizowano następujące zadania:**

*   **Zaprojektowano interfejs graficzny**, który obejmował ekran główny z przeglądem całego procesu oraz szczegółowe ekrany dla kluczowych urządzeń (kadź zacierna, kadź filtracyjna, itp.).
*   **Zaimplementowano dwa tryby sterowania:** manualny (do ręcznego załączania pomp, zaworów i mieszadeł) oraz automatyczny.
*   **Stworzono skrypty sekwencyjne** dla trybu automatycznego, które realizowały proces zacierania krok po kroku w oparciu o odczyty z czujników (temperatury, poziomu) oraz logikę czasową.
*   **Skonfigurowano kompleksowy system alarmów**, który wizualnie sygnalizował przekroczenia wartości granicznych i inne stany awaryjne bezpośrednio na schematach procesu.
*   **Dodano funkcjonalność wyświetlania trendów historycznych**, co umożliwia analizę archiwalnych danych procesowych w formie wykresów.
*   **Wprowadzono system logowania** z podziałem na poziomy dostępu (użytkownik, serwis), aby zabezpieczyć funkcje sterujące.


[![dokumentacjia PDF](SCADA_Browar_Paweł_Kwiatkowski_Szymon_Gołas.pdf)]
